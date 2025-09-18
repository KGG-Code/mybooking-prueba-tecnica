require 'json'

module Service
  class PricingService

    #
    # Get price definitions with dynamic conditions
    #
    # @param conditions [Hash] Optional conditions
    # @return [Array] Array of price definitions with their relationships
    #
    def retrieve(conditions = {})
      where_clause = build_where_clause(conditions)
      params = build_params(conditions)
      prices_params = build_prices_params(conditions)
      pagination_clause = build_pagination_clause(conditions)

      # Query optimizada con subquery pre-filtrada
      sql = <<-SQL
        SELECT
          rl.name as rental_location_name,
          rt.name as rate_type_name,
          c.code as category_code,
          c.name as category_name,
          pd.id as price_definition_id,

          COALESCE(
            JSON_ARRAYAGG(
              CASE 
                WHEN p.id IS NOT NULL THEN
                  JSON_OBJECT(
                    'season_id',        p.season_id,
                    'units',            p.units,
                    'time_measurement', p.time_measurement,
                    'price',            p.price
                  )
                ELSE NULL
              END
              ORDER BY p.time_measurement, p.season_id, p.units
            ),
            JSON_ARRAY()
          ) AS prices_json_string
          
        FROM category_rental_location_rate_types crlrt
        INNER JOIN rental_locations rl ON crlrt.rental_location_id = rl.id
        INNER JOIN rate_types rt ON crlrt.rate_type_id = rt.id
        INNER JOIN categories c ON crlrt.category_id = c.id
        INNER JOIN price_definitions pd ON crlrt.price_definition_id = pd.id
        LEFT JOIN (
          -- Subquery optimizada para prices con filtrado temprano
          SELECT 
            p.*,
            s.season_definition_id
          FROM prices p
          LEFT JOIN seasons s ON s.id = p.season_id
          WHERE 1=1
            #{build_prices_where_clause(conditions)}
        ) p ON p.price_definition_id = pd.id 
          AND (p.season_id IS NULL OR p.season_definition_id = pd.season_definition_id)
        #{where_clause}
        GROUP BY c.id, c.code, c.name, rl.name, rt.name, pd.id
        ORDER BY
          rl.name,
          rt.name,
          c.code
        #{pagination_clause}
      SQL

      # Combinar parámetros: primero los de la subquery, luego los principales
      all_params = prices_params + params
      results = Infraestructure::Query.run(sql, *all_params)
      
      # Process results to convert JSON_ARRAYAGG to array format
      results.map do |row|
        category_hash = row.to_h
        
        # Convert prices_json_string to prices array
        prices_json_value = category_hash['prices_json_string'] || category_hash[:prices_json_string]
        if prices_json_value && !prices_json_value.nil?
          prices_array = JSON.parse(prices_json_value)
          category_hash['prices'] = prices_array
        else
          category_hash['prices'] = []
        end

        category_hash.delete('prices_json_string')
        category_hash.delete(:prices_json_string)
        category_hash
      end
    end

    #
    # Get total count of price definitions with dynamic conditions
    #
    # @param conditions [Hash] Optional conditions
    # @return [Integer] Total count of records
    #
    def count(conditions = {})
      where_clause = build_where_clause(conditions)
      params = build_params(conditions)
      
      sql = <<-SQL
        SELECT COUNT(DISTINCT pd.id)
        FROM price_definitions pd
        JOIN category_rental_location_rate_types crlrt ON pd.id = crlrt.price_definition_id
        JOIN rental_locations rl ON crlrt.rental_location_id = rl.id
        JOIN rate_types rt ON crlrt.rate_type_id = rt.id
        JOIN categories c ON crlrt.category_id = c.id
        LEFT JOIN prices p ON pd.id = p.price_definition_id
        #{where_clause}
      SQL

      result = Infraestructure::Query.run(sql, *params)
      result.first&.to_i || 0
    end

    #
    # Get price definitions with pagination metadata
    #
    # @param conditions [Hash] Optional conditions including pagination
    # @return [Hash] Structured response with pagination metadata
    #
    def paginate(conditions = {})
      # Extract pagination parameters
      page = conditions[:page]&.to_i || 1
      per_page = conditions[:page] ? (conditions[:per_page]&.to_i || 10) : nil
      
      # Get data
      data = retrieve(conditions)
      
      # If no pagination, return simple array
      return data unless per_page
      
      # Get total count using optimized COUNT query
      count_conditions = conditions.dup
      count_conditions.delete(:page)
      count_conditions.delete(:per_page)
      total = count(count_conditions)
      
      # Calculate pagination metadata
      last_page = (total.to_f / per_page).ceil
      last_page = 1 if last_page < 1
      
      {
        page: page,
        per_page: per_page,
        last_page: last_page,
        total: total,
        data: data
      }
    end

    #
    # Get units list as comma-separated string for specific filters
    #
    # @param conditions [Hash] Conditions
    # @return [String] Comma-separated string of units values
    #
    def get_units_list_by_filters(conditions = {})
      where_clause = build_where_clause(conditions)
      params = build_params(conditions)
      
      sql = <<-SQL
        SELECT GROUP_CONCAT(DISTINCT p.units ORDER BY p.units ASC SEPARATOR ',') as units_string
        FROM prices p
        JOIN price_definitions pd ON p.price_definition_id = pd.id
        JOIN category_rental_location_rate_types crlrt ON pd.id = crlrt.price_definition_id
        JOIN rental_locations rl ON crlrt.rental_location_id = rl.id
        JOIN rate_types rt ON crlrt.rate_type_id = rt.id
        JOIN categories c ON crlrt.category_id = c.id
        #{where_clause}
      SQL

      result = Infraestructure::Query.run(sql, *params)
      result.first&.to_s || ""
    end

    private

      #
      # Build WHERE clause dynamically based on conditions
      #
      # @param conditions [Hash] Conditions to apply
      # @return [String] WHERE clause string
      #
      def build_where_clause(conditions)
        return "" if conditions.empty?
        
        clauses = []
        
        # Required filters
        clauses << "rl.id = ?" if conditions[:rental_location_id]
        clauses << "rt.id = ?" if conditions[:rate_type_id]
        
        # Required nullable filter
        if conditions[:season_definition_id]
          if conditions[:season_definition_id] == :explicit_null || conditions[:season_definition_id].to_s.downcase == 'null'
            clauses << "pd.season_definition_id IS NULL"
          else
            clauses << "pd.season_definition_id = ?"
          end
        end
        
        # Note: season_id and unit filters are now handled in the subquery
        # They should not be included here to avoid duplication
        
        clauses.any? ? "WHERE #{clauses.join(' AND ')}" : ""
      end

      #
      # Build parameters array for the query
      #
      # @param conditions [Hash] Conditions to apply
      # @return [Array] Array of parameter values
      #
      def build_params(conditions)
        params = []
        
        # Required filters
        params << conditions[:rental_location_id] if conditions[:rental_location_id]
        params << conditions[:rate_type_id] if conditions[:rate_type_id]
        
        # Required nullable filter
        if conditions[:season_definition_id]
          if conditions[:season_definition_id] != :explicit_null && conditions[:season_definition_id].to_s.downcase != 'null'
            params << conditions[:season_definition_id]
          end
        end
      
        params
      end

      #
      # Build pagination clause dynamically based on conditions
      #
      # @param conditions [Hash] Conditions to apply
      # @return [String] LIMIT/OFFSET clause string
      #
      def build_pagination_clause(conditions)
        return "" unless conditions[:page] && conditions[:per_page]
        
        page = conditions[:page].to_i
        per_page = conditions[:per_page].to_i
        
        # Ensure valid values
        page = 1 if page < 1
        per_page = 10 if per_page < 1
        per_page = 100 if per_page > 100  # Max limit
        
        offset = (page - 1) * per_page
        "LIMIT #{per_page} OFFSET #{offset}"
      end

      #
      # Build WHERE clause for prices subquery
      #
      # @param conditions [Hash] Conditions to apply
      # @return [String] WHERE clause string for prices
      #
      def build_prices_where_clause(conditions)
        clauses = []
        
        # Optional season_id filter
        if conditions[:season_id]
          if conditions[:season_id] == :explicit_null || conditions[:season_id].to_s.downcase == 'null'
            clauses << "AND p.season_id IS NULL"
          else
            clauses << "AND p.season_id = ?"
          end
        end
        
        # Optional unit filter (time_measurement)
        if conditions[:unit]
          clauses << "AND p.time_measurement = ?"
        end
        
        clauses.join(' ')
      end

      #
      # Build parameters array for prices subquery
      #
      # @param conditions [Hash] Conditions to apply
      # @return [Array] Array of parameter values for prices subquery
      #
      def build_prices_params(conditions)
        params = []
        
        # Optional season_id filter
        if conditions[:season_id]
          if conditions[:season_id] != :explicit_null && conditions[:season_id].to_s.downcase != 'null'
            params << conditions[:season_id]
          end
        end
        
        # Optional unit filter
        if conditions[:unit]
          params << conditions[:unit]
        end
        
        params
      end

  end
end