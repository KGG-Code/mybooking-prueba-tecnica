class SeasonFilterOpenParamsContract
    attr_reader :attributes, :rules
  
    def initialize(attributes)
      @attributes = attributes
      @rules = {
        season_definition_id: [:optional, :nullable, :int]
      }
    end
  end

class SeasonFilterParamsContract
    attr_reader :attributes, :rules
  
    def initialize(attributes)
      @attributes = attributes
      @rules = {
        season_definition_id: [:required, :int]
      }
    end
  end