require 'json'

module Service
  class PricingService

    #
    # Get price definitions with dynamic conditions
    #
    # @param conditions [Hash] Optional conditions like { season_definition_id: 1 }
    # @return [Array] Array of price definitions with their relationships
    #
  def get_price_definitions(conditions = {})
    where_clause = build_where_clause(conditions)
    params = build_params(conditions)
    pagination_clause = build_pagination_clause(conditions)

    sql = <<-SQL
      SELECT
        rl.name as rental_location_name,
        rt.name as rate_type_name,
        c.code as category_code,
        c.name as category_name,
        pd.id as price_definition_id,
        GROUP_CONCAT(
          CONCAT(
            '{"season_id":', p.season_id,
            ',"units":', p.units,
            ',"time_measurement":', p.time_measurement,
            ',"price":', p.price, '}'
          ) SEPARATOR ','
        ) as prices_json_string
        
      FROM categories c
      JOIN category_rental_location_rate_types crlrt
        ON crlrt.category_id = c.id
      JOIN rental_locations rl
        ON crlrt.rental_location_id = rl.id
      JOIN rate_types rt
        ON crlrt.rate_type_id = rt.id
      JOIN price_definitions pd
        ON pd.id = crlrt.price_definition_id
      JOIN prices p
        ON p.price_definition_id = pd.id
      #{where_clause}
      GROUP BY c.id, c.code, c.name, rl.name, rt.name, pd.id
      ORDER BY c.code
      #{pagination_clause}
    SQL

    results = Infraestructure::Query.run(sql, *params)
    
    # Process results to convert JSON_ARRAYAGG to array format
    results.map do |row|
      category_hash = row.to_h
      
      # Convert prices_json_string to prices array
      prices_json_value = category_hash['prices_json_string'] || category_hash[:prices_json_string]
      if prices_json_value && !prices_json_value.nil?
        # Wrap the concatenated JSON objects in an array
        json_array_string = "[#{prices_json_value}]"
        prices_array = JSON.parse(json_array_string)
        # Sort by units
        prices_array = prices_array.sort_by { |price| price['units'].to_i }
        
        category_hash['prices'] = prices_array
      else
        category_hash['prices'] = []
      end
      
      # Remove the prices_json_string field as it's not needed in the response
      category_hash.delete('prices_json_string')
      category_hash.delete(:prices_json_string)
      category_hash
    end
  end

  #
  # Get total count of price definitions with dynamic conditions
  #
  # @param conditions [Hash] Optional conditions like { season_definition_id: 1 }
  # @return [Integer] Total count of records
  #
  def get_price_definitions_count(conditions = {})
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
  def get_price_definitions_paginated(conditions = {})
    # Extract pagination parameters
    page = conditions[:page]&.to_i || 1
    per_page = conditions[:page] ? (conditions[:per_page]&.to_i || 10) : nil
    
    # Get data
    data = get_price_definitions(conditions)
    
    # If no pagination, return simple array
    return data unless per_page
    
    # Get total count using optimized COUNT query
    count_conditions = conditions.dup
    count_conditions.delete(:page)
    count_conditions.delete(:per_page)
    total = get_price_definitions_count(count_conditions)
    
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
        if conditions[:season_definition_id].to_s.downcase == 'null'
          clauses << "pd.season_definition_id IS NULL"
        else
          clauses << "pd.season_definition_id = ?"
        end
      end
      
      # Optional season_id filter (now we can filter prices directly)
      if conditions[:season_id]
        clauses << "p.season_id = ?"
      end
      
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
        if conditions[:season_definition_id].to_s.downcase != 'null'
          params << conditions[:season_definition_id]
        end
        # If season_definition_id is 'null', don't add any parameters for season filters
      end
      
      # Optional season_id filter
      params << conditions[:season_id] if conditions[:season_id]
      
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

  end
end