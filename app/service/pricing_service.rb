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
          pd.id as pd_id,
          pd.name as pd_name,
          pd.type as pd_type,
          pd.deposit as pd_deposit,
          pd.excess as pd_excess,
          pd.time_measurement_months as pd_time_measurement_months,
          pd.time_measurement_days as pd_time_measurement_days,
          pd.time_measurement_hours as pd_time_measurement_hours,
          pd.time_measurement_minutes as pd_time_measurement_minutes,
          pd.units_management_days as pd_units_management_days,
          pd.units_management_hours as pd_units_management_hours,
          pd.units_management_minutes as pd_units_management_minutes,
          pd.units_management_value_days_list as pd_units_management_value_days_list,
          pd.units_management_value_hours_list as pd_units_management_value_hours_list,
          pd.units_management_value_minutes_list as pd_units_management_value_minutes_list,
          pd.units_value_limit_hours_day as pd_units_value_limit_hours_day,
          pd.units_value_limit_min_hours as pd_units_value_limit_min_hours,
          pd.apply_price_by_kms as pd_apply_price_by_kms,
          pd.rate_type_id as pd_rate_type_id,
          pd.season_definition_id as pd_season_definition_id,
          p.id as p_id,
          p.time_measurement as p_time_measurement,
          p.units as p_units,
          p.price as p_price,
          p.included_km as p_included_km,
          p.extra_km_price as p_extra_km_price,
          p.price_definition_id as p_price_definition_id,
          p.season_id as p_season_id,
          crlrt.id as crlrt_id,
          crlrt.category_id as crlrt_category_id,
          crlrt.rental_location_id as crlrt_rental_location_id,
          crlrt.rate_type_id as crlrt_rate_type_id,
          crlrt.price_definition_id as crlrt_price_definition_id,
          c.id as c_id,
          c.code as c_code,
          c.name as c_name
        FROM price_definitions pd
        LEFT JOIN prices p ON pd.id = p.price_definition_id
        LEFT JOIN category_rental_location_rate_types crlrt ON pd.id = crlrt.price_definition_id
        LEFT JOIN categories c ON crlrt.category_id = c.id
        #{where_clause}
        ORDER BY pd.name, p.id, crlrt.id
      SQL

    Infraestructure::Query.run(sql, *params)
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