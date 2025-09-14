# frozen_string_literal: true

require 'csv'
require 'ostruct'

module Adapters
  class PricingCsvReader
    def initialize(file)
      @file = file
    end

    def each_row
      csv = CSV.new(@file, headers: true)
      csv.each do |r|
        yield OpenStruct.new(
          category_code:        str_or_nil(r['category_code']),
          rental_location_name: str_or_nil(r['rental_location_name']),
          rate_type_name:       str_or_nil(r['rate_type_name']),
          season_name:          str_or_nil(r['season_name']),
          time_measurement:     r['time_measurement'], # puede ser "2" o "días"
          units:                to_i_or_nil(r['units']),
          price:                to_f_or_nil(r['price']),
          included_km:          to_i_or_nil(r['included_km']),
          extra_km_price:       to_f_or_nil(r['extra_km_price'])
        )
      end
    end

    private

    def str_or_nil(v)
      return nil if v.nil?
      s = v.to_s.strip
      s.empty? ? nil : s
    end

    def to_i_or_nil(v)
      return nil if v.nil? || v.to_s.strip.empty?
      v.to_s.strip.to_i
    end

    def to_f_or_nil(v)
      return nil if v.nil? || v.to_s.strip.empty?
      v.to_s.strip.tr(',', '.').to_f
    end
  end
end
