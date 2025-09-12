module Model
  #
  # It represents a price definition
  #
  class PriceDefinition
     include DataMapper::Resource
     storage_names[:default] = 'price_definitions'

     property :id, Serial
     property :name, String, length: 255
     property :type, Enum[:season, :no_season], default: :season

     belongs_to :rate_type, 'Model::RateType', required: true
     belongs_to :season_definition, 'Model::SeasonDefinition', required: false

     # Relationships
     has n, :category_rental_location_rate_types, 'Model::CategoryRentalLocationRateType'
     has n, :prices, 'Model::Price'

     property :excess, Decimal, precision: 10, scale: 2
     property :deposit, Decimal, precision: 10, scale: 2

     property :time_measurement_months, Boolean, default: false
     property :time_measurement_days, Boolean, default: true
     property :time_measurement_hours, Boolean, default: false
     property :time_measurement_minutes, Boolean, default: false

     property :units_management_days, Enum[:unitary, :detailed], :default => :unitary
     property :units_management_hours, Enum[:unitary, :detailed], :default => :unitary
     property :units_management_minutes, Enum[:unitary, :detailed], :default => :unitary

     property :units_management_value_days_list, String, length: 255, default: '1' # comma-separated values
     property :units_management_value_hours_list, String, length: 255, default: '1' # comma-separated values
     property :units_management_value_minutes_list, String, length: 255, default: '1' # comma-separated values

     property :units_value_limit_hours_day, Integer, default: 0 # hours considered measurement in days. 0 no limit
     property :units_value_limit_min_hours, Integer, default: 0 # minutes considered measurement in hours. 0 no limit

     property :apply_price_by_kms, Boolean, default: false

  end
end
