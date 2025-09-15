# frozen_string_literal: true

require 'set'

module Utils
  module Resolvers
    # Lee price_definitions.* para determinar si un time_measurement está habilitado
    # y qué units están permitidas (según units_management_value_*_list).
    #
    # Map TM -> english word:
    #   1 => months, 2 => days, 3 => hours, 4 => minutes
    class AllowedUnitsFromPriceDefinitionResolver
    TM_MAP = {
      1 => 'months',
      2 => 'days',
      3 => 'hours',
      4 => 'minutes'
    }.freeze

    def initialize(price_definition_repo:, logger: nil)
      @pd_repo = price_definition_repo
      @logger  = logger
      @cache   = {} # {[pd_id, tm] => Set[Integer]}
    end

    # Devuelve Set de unidades permitidas; Set vacío si:
    # - no existe la PD,
    # - el time_measurement no está habilitado en la PD (flag = 0),
    # - o la lista está vacía.
    def call(row)
      price_definition_id = row.price_definition_id
      time_measurement = row.time_measurement
      
      key = [price_definition_id, time_measurement.to_i]
      return @cache[key] if @cache.key?(key)

      word = TM_MAP[time_measurement.to_i]
      unless word
        @logger&.warn "[AllowedUnitsFromPD] TM desconocido: #{time_measurement.inspect}"
        return @cache[key] = Set.new
      end

      pd = find_pd(price_definition_id)
      unless pd
        @logger&.warn "[AllowedUnitsFromPD] PD no encontrada id=#{price_definition_id}"
        return @cache[key] = Set.new
      end

      # 1) Flag habilitador: time_measurement_<word> == 1
      flag_attr = :"time_measurement_#{word}"
      enabled   = truthy?(read_attr(pd, flag_attr))
      unless enabled
        @logger&.info "[AllowedUnitsFromPD] TM #{word} deshabilitado en PD=#{price_definition_id}"
        return @cache[key] = Set.new
      end

      # 2) Lista de unidades: units_management_value_<word>_list (CSV string)
      list_attr = :"units_management_value_#{word}_list"
      csv       = (read_attr(pd, list_attr) || '').to_s
      set       = csv_to_int_set(csv)

      @cache[key] = set
    rescue => e
      @logger&.error "[AllowedUnitsFromPD] #{e.class}: #{e.message}"
      @cache[key] = Set.new
    end

    private

    def find_pd(id)
      # BaseRepository expone find_by_id(ids)
      @pd_repo.find_by_id(id)
    end

    def read_attr(record, name)
      record.respond_to?(name) ? record.public_send(name) : nil
    end

    def truthy?(v)
      v == true || v.to_s == '1' || v.to_s.downcase == 'true'
    end

    def csv_to_int_set(csv)
      require 'set'
      tokens = csv.split(',').map { |t| t.strip }.reject(&:empty?)
      Set.new(
        tokens.map { |t| int_or_nil(t) }.compact
      )
    end

    def int_or_nil(v)
      s = v.to_s.strip
      return nil if s.empty?
      /\A-?\d+\z/ === s ? s.to_i : nil
    end
    end
  end
end