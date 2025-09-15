# frozen_string_literal: true

module Utils
  module Resolvers
    class TimeMeasurementResolver

    TIME_UNIT_MAPPING = {
      1 => "meses",
      2 => "días", 
      3 => "horas",
      4 => "minutos"
    }.freeze

    def initialize
      @cache = {}
    end

    def call(time_measurement)
      return 'Sin Medida' if time_measurement.nil? || time_measurement == 0
      
      @cache[time_measurement] ||= begin
        TIME_UNIT_MAPPING[time_measurement] || "Medida #{time_measurement}"
      end
    rescue StandardError
      "Medida #{time_measurement}"
    end
    end
  end
end