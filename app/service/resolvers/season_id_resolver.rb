# frozen_string_literal: true

module Service
    module Resolvers
      # Resuelve season_id a partir de season_name
      # Regla: "Sin Temporada" o vacío => nil
      class SeasonIdResolver
        def initialize(season_repo:, logger: nil)
          @seasons = season_repo
          @logger  = logger
        end
  
        def call(name)
          return nil if name.nil? || name.to_s.strip.empty?
          return nil if name.to_s.strip.downcase == 'sin temporada'
  
          season = @seasons.first(name: name)
          season&.id
        rescue => e
          @logger&.error("[SeasonIdResolver] #{e.class}: #{e.message}")
          nil
        end
      end
    end
  end
  