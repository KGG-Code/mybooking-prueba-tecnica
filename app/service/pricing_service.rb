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
          p.season_id as season_id
        FROM price_definitions pd
        JOIN category_rental_location_rate_types crlrt ON pd.id = crlrt.price_definition_id
        JOIN rental_locations rl ON crlrt.rental_location_id = rl.id
        JOIN rate_types rt ON crlrt.rate_type_id = rt.id
        JOIN categories c ON crlrt.category_id = c.id
        LEFT JOIN prices p ON pd.id = p.price_definition_id
        #{where_clause}
        ORDER BY pd.name
        #{pagination_clause}
      SQL

    Infraestructure::Query.run(sql, *params)
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

  #
  # Get unique units list for a specific season and time measurement
  #
  # @param season_id [Integer] Season ID to filter by
  # @param time_measurement [Integer] Time measurement to filter by
  # @return [Array] Array with units_list result
  #
  def get_units_list_by_season_and_time_measurement(season_id, time_measurement)
    sql = <<-SQL
      SELECT GROUP_CONCAT(DISTINCT units ORDER BY units SEPARATOR ',') AS units_list
      FROM prices
      WHERE season_id = ?
        AND time_measurement = ?
    SQL

    Infraestructure::Query.run(sql, season_id, time_measurement)
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
      
      # Optional filter
      clauses << "p.season_id = ?" if conditions[:season_id]
      
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
      if conditions[:season_definition_id] && conditions[:season_definition_id].to_s.downcase != 'null'
        params << conditions[:season_definition_id]
      end
      
      # Optional filter
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