module Model
  #
  # It represents a rate type
  #
  class RateType
     include DataMapper::Resource
     storage_names[:default] = 'rate_types'

     property :id, Serial
     property :name, String, length: 255, required: true

     # Relationships
     has n, :category_rental_location_rate_types, 'Model::CategoryRentalLocationRateType'
     has n, :rental_locations, through: :category_rental_location_rate_types
     has n, :categories, through: :category_rental_location_rate_types

  end
end
