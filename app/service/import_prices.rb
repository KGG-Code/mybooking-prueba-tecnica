# frozen_string_literal: true
require "csv"
require "bigdecimal"
require_relative "../model/price"
require_relative "../model/price_definition"
require_relative "../model/category"
require_relative "../model/rental_location"
require_relative "../model/rate_type"
require_relative "../model/season"
require_relative "../model/season_definition"
require_relative "../model/category_rental_location_rate_type"

module Service
  class ImportPrices
    TIME_MEAS_MAP = {
      "dias" => 2, "días" => 2, "day" => 2, "days" => 2,
      "horas" => 3, "hora" => 3, "hours" => 3, "hour" => 3,
      "minutos" => 4, "minuto" => 4, "mins" => 4, "minutes" => 4,
      "meses" => 1, "mes" => 1, "months" => 1, "month" => 1
    }.freeze

    def initialize(price_repository, logger:)
      @price_repository = price_repository
      @logger = logger
      # caches
      @cat_by_code = {}
      @rl_by_name  = {}
      @rt_by_name  = {}
      @sd_by_name  = {}
      @season_by_key = {}      # ["SD name","Season name"] => Season.id
      @pd_by_crlrt = {}        # [cat_id, rl_id, rt_id] => [pd.id, pd.season_definition_id]
      @allowed_cache = {}      # [pd_id, tm] => [ints]
    end

    def call(csv_path)
        run(csv_path)
    end

    def run(csv_path)
      info "Importando #{csv_path}…"
      processed_rows = 0
      skipped_rows = 0
      
      CSV.foreach(csv_path, headers: true) do |row|
        begin
          h = normalize(row)
          
          # Saltar filas completamente vacías
          if h.values.all? { |v| v.nil? || (v.respond_to?(:empty?) && v.empty?) }
            skipped_rows += 1
            next
          end

          # ---- validaciones de presencia mínima
          required = %i[category_code rental_location_name rate_type_name season_name time_measurement units]
          unless required.all? { |k| present?(h[k]) }
            warn "Fila con campos faltantes: #{h.inspect}"
            skipped_rows += 1
            next
          end

          # De dias a 2
          tm = map_time_measurement(h[:time_measurement])
          unless tm
            warn "time_measurement desconocido: #{h[:time_measurement].inspect}"
            skipped_rows += 1
            next
          end

          # ---- lookups base
          category        = find_category(h[:category_code])
          rental_location = find_rental_location(h[:rental_location_name])
          rate_type       = find_rate_type(h[:rate_type_name])
          unless category && rental_location && rate_type
            warn "No se resolvió category/location/rate_type: #{h.values_at(:category_code,:rental_location_name,:rate_type_name).inspect}"
            skipped_rows += 1
            next
          end

          pd_id, pd_sd_id = find_price_definition_for(category.id, rental_location.id, rate_type.id)
          unless pd_id
            warn "No hay PriceDefinition vía CRLRT para #{category.code}/#{rental_location.name}/#{rate_type.name}"
            skipped_rows += 1
            next
          end

          # Buscar season directamente por nombre sin validar season_definition
          season = find_season_by_name(h[:season_name], pd_sd_id)
          unless season
            warn "Season '#{h[:season_name]}' no encontrado para PriceDefinition #{pd_id}"
            skipped_rows += 1
            next
          end

          # ---- validar unidades permitidas según tm
          units = h[:units].to_i
          #allowed = allowed_units(pd_id, tm)
          #unless allowed.include?(units)
          #  info "Unidad #{units} no permitida en PD #{pd_id} para #{h[:time_measurement]} (permitidas: #{allowed.join(",")}) -> ignoro fila"
          #  skipped_rows += 1
          #  next
          #end

          # ---- upsert en prices
          price_record = @price_repository.first(
            price_definition_id: pd_id,
            season_id: season.id,
            time_measurement: tm,
            units: units
          ) || @price_repository.model_class.new(
            price_definition_id: pd_id,
            season_id: season.id,
            time_measurement: tm,
            units: units
          )
          price_record.price          = to_decimal_or_nil(h[:price])
          price_record.included_km    = to_int_or_zero(h[:included_km])
          price_record.extra_km_price = to_decimal_or_zero(h[:extra_km_price])

          # Log de valores que se intentan guardar
          info "Intentando guardar: price_definition_id=#{price_record.price_definition_id}, season_id=#{price_record.season_id}, time_measurement=#{price_record.time_measurement}, units=#{price_record.units}, price=#{price_record.price}, included_km=#{price_record.included_km}, extra_km_price=#{price_record.extra_km_price}"

          if price_record.save
            info "OK #{category.code}/#{rental_location.name}/#{rate_type.name} | #{season.name} #{units} #{h[:time_measurement]} => #{price_record.price}"
            processed_rows += 1
          else
            error_details = price_record.errors.full_messages.join(", ")
            warn "ERROR al guardar: #{category.code}/#{rental_location.name}/#{rate_type.name} | #{season.name} #{units} #{h[:time_measurement]} => #{price_record.price} | Valores: price_definition_id=#{price_record.price_definition_id}, season_id=#{price_record.season_id}, time_measurement=#{price_record.time_measurement}, units=#{price_record.units}, price=#{price_record.price}, included_km=#{price_record.included_km}, extra_km_price=#{price_record.extra_km_price} | Errores: #{error_details}"        
            warn "---- Intentando guardar: price_definition_id=#{price_record.price_definition_id}, season_id=#{price_record.season_id}, time_measurement=#{price_record.time_measurement}, units=#{price_record.units}, price=#{price_record.price}, included_km=#{price_record.included_km}, extra_km_price=#{price_record.extra_km_price}"
            skipped_rows += 1
          end
        rescue => e
          warn "EXCEPCIÓN procesando fila: #{h.inspect rescue 'datos no disponibles'} | Error: #{e.message}"
          skipped_rows += 1
        end
      end
      
      info "Importación finalizada. Procesadas: #{processed_rows}, Omitidas: #{skipped_rows}"
    end

    private

    # ---- helpers de normalización
    def normalize(row)
      row.to_h.each_with_object({}) do |(k,v),h|
        h[k.to_s.strip.downcase.gsub(/\s+/, "_").to_sym] = v.is_a?(String) ? v.strip : v
      end
    end

    def present?(v) = !(v.nil? || (v.respond_to?(:empty?) && v.empty?))

    def map_time_measurement(txt) = TIME_MEAS_MAP[txt.to_s.downcase]

    def to_decimal_or_nil(s)
      s = s.to_s.strip
      return nil if s.empty?
      BigDecimal(s)
    rescue ArgumentError
      nil
    end

    def to_int_or_nil(s)
      s = s.to_s.strip
      return nil if s.empty?
      Integer(s) rescue nil
    end

    def to_decimal_or_zero(s)
      s = s.to_s.strip
      return BigDecimal('0') if s.empty?
      BigDecimal(s)
    rescue ArgumentError
      BigDecimal('0')
    end

    def to_int_or_zero(s)
      s = s.to_s.strip
      return 0 if s.empty?
      Integer(s) rescue 0
    end

    # ---- lookups con cache (ActiveRecord)

    def find_category(code)
      @cat_by_code[code] ||= Model::Category.first(code: code)
    end

    def find_rental_location(name)
      @rl_by_name[name] ||= Model::RentalLocation.first(name: name)
    end

    def find_rate_type(name)
      @rt_by_name[name] ||= Model::RateType.first(name: name)
    end

    # -> [pd.id, pd.season_definition_id] o [nil, nil]
    def find_price_definition_for(category_id, rental_location_id, rate_type_id)
      key = [category_id, rental_location_id, rate_type_id]
      return @pd_by_crlrt[key] if @pd_by_crlrt.key?(key)

      cr = Model::CategoryRentalLocationRateType.first(category_id: category_id, rental_location_id: rental_location_id, rate_type_id: rate_type_id)
      pd = cr && Model::PriceDefinition.first(id: cr.price_definition_id)
      @pd_by_crlrt[key] = pd ? [pd.id, pd.season_definition_id] : [nil, nil]
    end

    def find_season_by_name(season_name, season_definition_id)
      # Buscar season por nombre dentro del season_definition de la price_definition
      key = [season_definition_id, season_name]
      @season_by_key[key] ||= Model::Season.first(season_definition_id: season_definition_id, name: season_name)
    end

    def find_season_in_definition(sd_name, season_name, required_sd_id:)
      # valida SD por nombre y que coincida con el de la PD
      sd = @sd_by_name[sd_name] ||= Model::SeasonDefinition.first(name: sd_name)
      return nil unless sd && sd.id == required_sd_id

      key = [sd_name, season_name]
      @season_by_key[key] ||= Model::Season.first(season_definition_id: sd.id, name: season_name)
    end

    # devuelve array de ints
    def allowed_units(pd_id, tm)
      key = [pd_id, tm]
      return @allowed_cache[key] if @allowed_cache.key?(key)

      pd = Model::PriceDefinition.first(id: pd_id)
      csv = case tm
            when 2 then pd.units_management_value_days_list
            when 3 then pd.units_management_value_hours_list
            when 4 then pd.units_management_value_minutes_list
            when 1 then pd.units_management_value_months_list
            end
      list = (csv || "").split(",").map { _1.strip }.reject(&:empty?).map!(&:to_i)
      @allowed_cache[key] = list
    end

    def info(msg) = @logger.info("[INFO] #{msg}")
    def warn(msg) = @logger.warn("[WARN] #{msg}")
  end
end
