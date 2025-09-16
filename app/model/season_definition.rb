module Model
  #
  # It represents a season definition
  #
  class SeasonDefinition
     include DataMapper::Resource
     storage_names[:default] = 'season_definitions'

     property :id, Serial
     property :name, String, length: 255, required: true

     # Relationships
     has n, :price_definitions, 'Model::PriceDefinition'
     has n, :seasons, 'Model::Season'
     has n, :season_definition_rental_locations, 'Model::SeasonDefinitionRentalLocation'
     has n, :rental_locations, 'Model::RentalLocation', through: :season_definition_rental_locations

  end
end
