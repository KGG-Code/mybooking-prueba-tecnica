class SeasonDefinitionFilterOpenParamsContract
    attr_reader :attributes, :rules
  
    def initialize(attributes)
      @attributes = attributes
      @rules = {
        rate_type_id: [:optional, :nullable, :int],
        rental_location_id: [:optional, :nullable, :int]
      }
    end
  end

class SeasonDefinitionFilterParamsContract
    attr_reader :attributes, :rules
  
    def initialize(attributes)
      @attributes = attributes
      @rules = {
        rate_type_id: [:required, :int],
        rental_location_id: [:required, :int]
      }
    end
  end