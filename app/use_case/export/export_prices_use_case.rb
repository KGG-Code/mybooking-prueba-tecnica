# frozen_string_literal: true

require 'csv'

module UseCase
  module Export
    class ExportPricesUseCase
      Result = Struct.new(:success?, :message, keyword_init: true)

      def initialize(reader:, exporter:, validator:, logger: nil)
        @reader    = reader
        @exporter  = exporter
        @validator = validator
        @logger    = logger
      end

      def perform(path, input: {}, options: {})
        File.open(path, 'wb') { |file| call(io: file, input: input, options: options) }
        Result.new(success?: true)
      rescue Validation::Error => e
        @logger&.warn("[ExportPricesUseCase] validation failed: #{e.message}")
        Result.new(success?: false, message: e.message)
      rescue => e
        @logger&.error("[ExportPricesUseCase] unexpected: #{e.class}: #{e.message}")
        Result.new(success?: false, message: 'Fallo inesperado en la exportación')
      end

      def call(io:, input: {}, options: {})
        safe_validate!(input)
        io << "\uFEFF" # BOM para Excel
        enum_proc = ->(&blk) { @reader.each(&blk) }
        options[:grouped] = true if options[:grouped].nil?
        @exporter.write(io, enum_proc, options)
      end

      private

      def safe_validate!(input)
        return unless @validator.respond_to?(:validate!)
        arity = @validator.method(:validate!).arity
        arity == 0 ? @validator.validate! : @validator.validate!(input)
      end
    end
  end
end
