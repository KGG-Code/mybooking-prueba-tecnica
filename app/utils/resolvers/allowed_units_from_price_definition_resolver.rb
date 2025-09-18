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

    def initialize(logger: nil)
      @logger  = logger
      @cache   = {} # {[pd_id, tm] => Set[Integer]}
    end

    def clear_cache!
      @cache.clear
      @logger&.info "[AllowedUnitsFromPD] Cache cleared"
    end

    # Devuelve Set de unidades permitidas; Set vacío si:
    # - no existe la PD,
    # - el time_measurement no está habilitado en la PD (flag = 0),
    # - o la lista está vacía.
    def call(price_definition, time_measurement)
      return Set.new unless price_definition
      
      price_definition_id = price_definition.id
      key = [price_definition_id, time_measurement.to_i]
      @logger&.info "[AllowedUnitsFromPD] DEBUG: called with pd_id=#{price_definition_id}, tm=#{time_measurement}, key=#{key.inspect}"
      @logger&.info "[AllowedUnitsFromPD] DEBUG: cache has key? #{@cache.key?(key)}"
      return @cache[key] if @cache.key?(key)

      word = TM_MAP[time_measurement.to_i]
      unless word
        @logger&.warn "[AllowedUnitsFromPD] TM desconocido: #{time_measurement.inspect}"
        return @cache[key] = Set.new
      end

      # 1) Flag habilitador: time_measurement_<word> == 1
      flag_attr = :"time_measurement_#{word}"
      @logger&.info "[AllowedUnitsFromPD] DEBUG: checking flag_attr=#{flag_attr}"
      enabled   = truthy?(read_attr(price_definition, flag_attr))
      @logger&.info "[AllowedUnitsFromPD] DEBUG: enabled=#{enabled}"
      unless enabled
        @logger&.info "[AllowedUnitsFromPD] TM #{word} deshabilitado en PD=#{price_definition_id}"
        return @cache[key] = Set.new
      end

      # 2) Lista de unidades: units_management_value_<word>_list (CSV string)
      list_attr = :"units_management_value_#{word}_list"
      @logger&.info "[AllowedUnitsFromPD] DEBUG: word=#{word}, list_attr=#{list_attr}"
      csv       = (read_attr(price_definition, list_attr) || '').to_s
      @logger&.info "[AllowedUnitsFromPD] DEBUG: csv value='#{csv}'"
      set       = csv_to_int_set(csv)
      @logger&.info "[AllowedUnitsFromPD] DEBUG: final set=#{set.inspect}"

      @cache[key] = set
    rescue => e
      @logger&.error "[AllowedUnitsFromPD] #{e.class}: #{e.message}"
      @cache[key] = Set.new
    end

    private

    def read_attr(record, name)
      @logger&.info "[AllowedUnitsFromPD] DEBUG: read_attr called with name=#{name}"
      @logger&.info "[AllowedUnitsFromPD] DEBUG: record class=#{record.class}"
      @logger&.info "[AllowedUnitsFromPD] DEBUG: record responds to #{name}? #{record.respond_to?(name)}"
      
      if record.respond_to?(name)
        value = record.public_send(name)
        @logger&.info "[AllowedUnitsFromPD] DEBUG: got value=#{value.inspect} (#{value.class})"
        value
      else
        @logger&.warn "[AllowedUnitsFromPD] DEBUG: record does not respond to #{name}"
        nil
      end
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