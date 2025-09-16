class RateTypeFilterOpenParamsContract
    attr_reader :attributes, :rules
  
    def initialize(attributes)
      @attributes = attributes
      @rules = {
        rental_location_id: [:optional, :nullable, :int],
      }
    end
  end

class RateTypeFilterParamsContract
    attr_reader :attributes, :rules
  
    def initialize(attributes)
      @attributes = attributes
      @rules = {
        rental_location_id: [:required, :int],
      }
    end
  end