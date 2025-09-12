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
      
      sql = <<-SQL
        SELECT 
          pd.id,
          pd.name,
          pd.type,
          pd.deposit,
          pd.excess,
          p.id as price_id,
          p.price,
          p.units,
          p.time_measurement,
          crlrt.id as category_rental_location_rate_type_id,
          crlrt.category_id as category_rt_id,
          crlrt.rental_location_id,
          crlrt.rate_type_id,
          c.id as category_id,
          c.code as category_code,
          c.name as category_name
        FROM price_definitions pd
        LEFT JOIN prices p ON pd.id = p.price_definition_id
        LEFT JOIN category_rental_location_rate_types crlrt ON pd.id = crlrt.price_definition_id
        LEFT JOIN categories c ON crlrt.category_id = c.id
        #{where_clause}
        ORDER BY pd.name, p.id, crlrt.id
      SQL

      Infraestructure::Query.run(sql, *params)
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
      clauses << "pd.season_definition_id = ?" if conditions[:season_definition_id]
      clauses << "pd.rate_type_id = ?" if conditions[:rate_type_id]
      clauses << "crlrt.rental_location_id = ?" if conditions[:rental_location_id]
      clauses << "crlrt.category_id = ?" if conditions[:category_id]
      
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
      params << conditions[:season_definition_id] if conditions[:season_definition_id]
      params << conditions[:rate_type_id] if conditions[:rate_type_id]
      params << conditions[:rental_location_id] if conditions[:rental_location_id]
      params << conditions[:category_id] if conditions[:category_id]
      params
    end

  end
end