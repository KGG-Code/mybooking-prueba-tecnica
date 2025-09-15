# frozen_string_literal: true

module UseCase
  module Import
    class ImportPricesCsvUseCase
      Result = Struct.new(:success?, :message, keyword_init: true)

      def initialize(reader:, importer:, validator:, logger: nil)
        @reader    = reader      # each_row { |row| ... }
        @importer  = importer
        @validator = validator
        @logger    = logger
      end

      def perform
        safe_validate!

        count = 0
        @reader.each_row do |row|
          @importer.import(row)
          count += 1
        end

        Result.new(success?: true, message: "Importadas #{count} filas")
      rescue Validation::Error => e
        @logger&.warn("[ImportPricesCsvUseCase] validation failed: #{e.message}")
        Result.new(success?: false, message: e.message)
      rescue => e
        @logger&.error("[ImportPricesCsvUseCase] unexpected: #{e.class}: #{e.message}")
        Result.new(success?: false, message: 'Fallo inesperado en la importación')
      end

      private

      def safe_validate!
        return unless @validator.respond_to?(:validate!)
        arity = @validator.method(:validate!).arity
        arity == 0 ? @validator.validate! : @validator.validate!({})
      end
    end
  end
end