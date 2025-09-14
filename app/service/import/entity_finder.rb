module Service
  module Import
    #
    # Servicio especializado en búsqueda de entidades relacionadas
    #
    class EntityFinder
      def initialize(category_repository, rental_location_repository, rate_type_repository, 
                     season_repository, price_definition_repository, category_rental_location_rate_type_repository, logger:)
        @category_repository = category_repository
        @rental_location_repository = rental_location_repository
        @rate_type_repository = rate_type_repository
        @season_repository = season_repository
        @price_definition_repository = price_definition_repository
        @category_rental_location_rate_type_repository = category_rental_location_rate_type_repository
        @logger = logger
        
        # Caches para optimizar búsquedas repetitivas
        @category_cache = {}
        @rental_location_cache = {}
        @rate_type_cache = {}
        @season_cache = {}
        @price_definition_cache = {}
      end

      #
      # Busca una categoría por código
      #
      # @param [String] code - Código de la categoría
      # @return [Model::Category, nil] Categoría encontrada o nil
      #
      def find_category(code)
        @category_cache[code] ||= @category_repository.first(code: code)
      end

      #
      # Busca una ubicación de alquiler por nombre
      #
      # @param [String] name - Nombre de la ubicación
      # @return [Model::RentalLocation, nil] Ubicación encontrada o nil
      #
      def find_rental_location(name)
        @rental_location_cache[name] ||= @rental_location_repository.first(name: name)
      end

      #
      # Busca un tipo de tarifa por nombre
      #
      # @param [String] name - Nombre del tipo de tarifa
      # @return [Model::RateType, nil] Tipo de tarifa encontrado o nil
      #
      def find_rate_type(name)
        @rate_type_cache[name] ||= @rate_type_repository.first(name: name)
      end

      #
      # Busca una temporada por nombre dentro de una definición de temporada
      #
      # @param [String] season_name - Nombre de la temporada
      # @param [Integer] season_definition_id - ID de la definición de temporada
      # @return [Model::Season, nil] Temporada encontrada o nil
      #
      def find_season_by_name(season_name, season_definition_id)
        key = [season_definition_id, season_name]
        @season_cache[key] ||= @season_repository.first(season_definition_id: season_definition_id, name: season_name)
      end

      #
      # Busca una definición de precio basada en categoría, ubicación y tipo de tarifa
      #
      # @param [Integer] category_id - ID de la categoría
      # @param [Integer] rental_location_id - ID de la ubicación
      # @param [Integer] rate_type_id - ID del tipo de tarifa
      # @return [Array] [price_definition_id, season_definition_id] o [nil, nil]
      #
      def find_price_definition_for(category_id, rental_location_id, rate_type_id)
        key = [category_id, rental_location_id, rate_type_id]
        return @price_definition_cache[key] if @price_definition_cache.key?(key)

        crlrt = @category_rental_location_rate_type_repository.first(
          category_id: category_id, 
          rental_location_id: rental_location_id, 
          rate_type_id: rate_type_id
        )
        
        if crlrt
          pd = @price_definition_repository.first(id: crlrt.price_definition_id)
          result = pd ? [pd.id, pd.season_definition_id] : [nil, nil]
        else
          result = [nil, nil]
        end
        
        @price_definition_cache[key] = result
        result
      end
    end
  end
end