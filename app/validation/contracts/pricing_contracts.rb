# frozen_string_literal: true

# Contract para validación de parámetros de filtrado de precios
# Basado en el estilo del pricing_controller.rb
class PricingContract
  attr_reader :attributes, :rules

  def initialize(attributes)
    @attributes = attributes
    @rules = {
      # Parámetros de filtrado (estilo pricing_controller)
      rental_location_id: [:optional, :int],
      rate_type_id: [:optional, :int],
      season_definition_id: [:optional, :nullable, :int],
      season_id: [:optional, :nullable, :int],
      unit: [:optional, :int, [:enum, 1, 2, 3, 4]], # meses, días, horas, minutos
      page: [:optional, :int],
      per_page: [:optional, :int],
    }
  end
end

# Contract específico para importación de precios CSV
class ImportPricesContract
  attr_reader :attributes, :rules

  def initialize(attributes)
    @attributes = attributes
    @rules = {
      category_code: [:required, :string],
      rental_location_name: [:required, :string],
      rate_type_name: [:required, :string],
      season_name: [:nullable, :string],
      time_measurement: [:required, [:enum, 'días', 'meses', 'horas', 'minutos', '1', '2', '3', '4']],
      units: [:required, :int],
      price: [:required, :numeric],
      included_km: [:nullable, :int],
      extra_km_price: [:nullable, :numeric]
    }
  end
end

# Contract específico para exportacion de precios CSV
class ExportPricesContract
  attr_reader :attributes, :rules

  def initialize(attributes)
    @attributes = attributes
    @rules = {}
  end
end

# Contract para parámetros de filtrado (como en pricing_controller)
class PricingFilterParamsContract
  attr_reader :attributes, :rules

  def initialize(attributes)
    @attributes = attributes
    @rules = {
      rental_location_id: [:required, :int],
      rate_type_id: [:required, :int],
      season_definition_id: [:optional, :nullable, :int],
      season_id: [:optional, :nullable, :int],
      unit: [:optional, :int, [:enum, 1, 2, 3, 4]], # meses, días, horas, minutos
      page: [:optional, :int],
      per_page: [:optional, :int]
    }
  end
end