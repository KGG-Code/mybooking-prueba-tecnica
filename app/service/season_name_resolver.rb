# frozen_string_literal: true

module Service
    class SeasonNameResolver
      def initialize(season_repository:)
        @repo  = season_repository
        @cache = {}
      end
  
      # API simple: resolver.call(season_id) -> "Nombre"
      def call(season_id)
        return 'Sin Temporada' if season_id.nil? || season_id == 0
        @cache[season_id] ||= begin
          season = @repo.first(id: season_id)
          season ? season.name : "Temporada #{season_id}"
        end
      rescue StandardError
        "Temporada #{season_id}"
      end
    end
  end
  