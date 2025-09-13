# Time Unit Constants Module
# Provides immutable constants for time unit operations across the application
module TimeUnitConstants
  
  # Mapping of integer values to time unit names
  TIME_UNIT_MAPPING = {
    1 => "month",
    2 => "days", 
    3 => "hours",
    4 => "minutes"
  }.freeze
  
  # Valid time unit values (1-4)
  VALID_TIME_UNITS = TIME_UNIT_MAPPING.keys.freeze
  
  # Time unit names as array
  TIME_UNIT_NAMES = TIME_UNIT_MAPPING.values.freeze
  
  # Reverse mapping for validation (name to integer)
  TIME_UNIT_REVERSE_MAPPING = TIME_UNIT_MAPPING.invert.freeze
  
  # Validation methods
  def self.valid_time_unit?(unit)
    VALID_TIME_UNITS.include?(unit)
  end
  
  def self.valid_time_unit_name?(name)
    TIME_UNIT_NAMES.include?(name)
  end
  
  def self.get_time_unit_name(unit)
    TIME_UNIT_MAPPING[unit]
  end
  
  def self.get_time_unit_value(name)
    TIME_UNIT_REVERSE_MAPPING[name]
  end
  
  # Database column mapping for price_definitions table
  # Maps time units to their corresponding boolean columns
  TIME_MEASUREMENT_COLUMNS = {
    1 => "time_measurement_month",
    2 => "time_measurement_days",
    3 => "time_measurement_hours", 
    4 => "time_measurement_minutes"
  }.freeze
  
  # Get the database column name for a time unit
  def self.get_time_measurement_column(unit)
    TIME_MEASUREMENT_COLUMNS[unit]
  end
  
  # Get all time measurement columns
  def self.get_all_time_measurement_columns
    TIME_MEASUREMENT_COLUMNS.values
  end
  
  # Validation for database operations
  def self.valid_for_database?(unit)
    valid_time_unit?(unit) && TIME_MEASUREMENT_COLUMNS.key?(unit)
  end
  
end