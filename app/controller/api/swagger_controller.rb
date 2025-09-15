module Controller
  module Api
    module SwaggerController

      def self.registered(app)

        #
        # Swagger UI endpoint
        #
        app.get '/swagger' do
          content_type :html
          <<-HTML
<!DOCTYPE html>
<html>
<head>
  <title>MyBooking API Documentation</title>
  <link rel="stylesheet" type="text/css" href="https://unpkg.com/swagger-ui-dist@4.15.5/swagger-ui.css" />
</head>
<body>
  <div id="swagger-ui"></div>
  <script src="https://unpkg.com/swagger-ui-dist@4.15.5/swagger-ui-bundle.js"></script>
  <script>
    SwaggerUIBundle({
      url: '/swagger.json',
      dom_id: '#swagger-ui',
      presets: [
        SwaggerUIBundle.presets.apis,
        SwaggerUIBundle.presets.standalone
      ]
    });
  </script>
</body>
</html>
          HTML
        end

        #
        # Swagger JSON specification
        #
        app.get '/swagger.json' do
          content_type :json
          {
            "openapi": "3.0.0",
            "info": {
              "title": "MyBooking API",
              "version": "1.0.0",
              "description": "API for managing rental locations and pricing"
            },
            "servers": [
              {
                "url": "http://localhost:9292",
                "description": "Development server"
              }
            ],
            "tags": [
              {
                "name": "Rental Locations",
                "description": "Operations related to rental locations"
              },
              {
                "name": "Rate Types",
                "description": "Operations related to rate types"
              },
              {
                "name": "Season Definitions",
                "description": "Operations related to season definitions"
              },
              {
                "name": "Seasons",
                "description": "Operations related to seasons"
              },
              {
                "name": "Pricing",
                "description": "Operations related to price definitions"
              },
              {
                "name": "Export",
                "description": "Operations related to data export"
              },
              {
                "name": "Import",
                "description": "Operations related to data import"
              }
            ],
            "paths": {
              "/api/rental-locations": {
                "get": {
                  "summary": "List all rental locations",
                  "description": "Returns a list of all rental locations ordered by name",
                  "operationId": "listRentalLocations",
                  "tags": ["Rental Locations"],
                  "responses": {
                    "200": {
                      "description": "successful operation",
                      "content": {
                        "application/json": {
                          "schema": {
                            "type": "array",
                            "items": {
                              "$ref": "#/components/schemas/RentalLocation"
                            }
                          }
                        }
                      }
                    },
                    "401": {
                      "description": "Unauthorized",
                      "content": {
                        "application/json": {
                          "schema": {
                            "type": "object",
                            "properties": {
                              "error": {
                                "type": "string",
                                "description": "Error message"
                              }
                            }
                          }
                        }
                      }
                    },
                    "400": {
                      "description": "Bad request",
                      "content": {
                        "application/json": {
                          "schema": {
                            "type": "object",
                            "properties": {
                              "error": {
                                "type": "string",
                                "description": "Error message"
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              },
              "/api/open-rate-types": {
                "get": {
                  "summary": "List rate types (open endpoint)",
                  "description": "Returns a list of rate types with optional rental location filter. This is an open endpoint that doesn't require authentication.",
                  "operationId": "listOpenRateTypes",
                  "tags": ["Rate Types"],
                  "parameters": [
                    {
                      "name": "rental_location_id",
                      "in": "query",
                      "description": "Filter rate types by rental location ID (optional)",
                      "required": false,
                      "schema": {
                        "type": "integer",
                        "format": "int64",
                        "minimum": 1
                      },
                      "example": 1
                    }
                  ],
                  "responses": {
                    "200": {
                      "description": "successful operation",
                      "content": {
                        "application/json": {
                          "schema": {
                            "type": "array",
                            "items": {
                              "$ref": "#/components/schemas/RateType"
                            }
                          }
                        }
                      }
                    },
                    "400": {
                      "description": "Bad request - invalid parameters",
                      "content": {
                        "application/json": {
                          "schema": {
                            "type": "object",
                            "properties": {
                              "error": {
                                "type": "string",
                                "description": "Error message"
                              }
                            }
                          }
                        }
                      }
                    },
                    "422": {
                      "description": "Validation error",
                      "content": {
                        "application/json": {
                          "schema": {
                            "type": "object",
                            "properties": {
                              "errors": {
                                "type": "object",
                                "description": "Validation errors by field"
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              },
              "/api/rate-types": {
                "get": {
                  "summary": "List rate types (authenticated endpoint)",
                  "description": "Returns a list of rate types filtered by rental location ID. This endpoint requires authentication and rental_location_id is mandatory.",
                  "operationId": "listRateTypes",
                  "tags": ["Rate Types"],
                  "parameters": [
                    {
                      "name": "rental_location_id",
                      "in": "query",
                      "description": "Rental location ID to filter rate types (required)",
                      "required": true,
                      "schema": {
                        "type": "integer",
                        "format": "int64",
                        "minimum": 1
                      },
                      "example": 1
                    }
                  ],
                  "responses": {
                    "200": {
                      "description": "successful operation",
                      "content": {
                        "application/json": {
                          "schema": {
                            "type": "array",
                            "items": {
                              "$ref": "#/components/schemas/RateType"
                            }
                          }
                        }
                      }
                    },
                    "401": {
                      "description": "Unauthorized",
                      "content": {
                        "application/json": {
                          "schema": {
                            "type": "object",
                            "properties": {
                              "error": {
                                "type": "string",
                                "description": "Error message"
                              }
                            }
                          }
                        }
                      }
                    },
                    "400": {
                      "description": "Bad request - rental_location_id is required",
                      "content": {
                        "application/json": {
                          "schema": {
                            "type": "object",
                            "properties": {
                              "error": {
                                "type": "string",
                                "description": "Error message"
                              }
                            }
                          }
                        }
                      }
                    },
                    "422": {
                      "description": "Validation error",
                      "content": {
                        "application/json": {
                          "schema": {
                            "type": "object",
                            "properties": {
                              "errors": {
                                "type": "object",
                                "description": "Validation errors by field"
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              },
              "/api/open-season-definitions": {
                "get": {
                  "summary": "List season definitions (open endpoint)",
                  "description": "Returns a list of season definitions with optional rate type and rental location filters. This is an open endpoint that doesn't require authentication.",
                  "operationId": "listOpenSeasonDefinitions",
                  "tags": ["Season Definitions"],
                  "parameters": [
                    {
                      "name": "rate_type_id",
                      "in": "query",
                      "description": "Filter season definitions by rate type ID (optional)",
                      "required": false,
                      "schema": {
                        "type": "integer",
                        "format": "int64",
                        "minimum": 1,
                        "nullable": true
                      },
                      "example": 1
                    },
                    {
                      "name": "rental_location_id",
                      "in": "query",
                      "description": "Filter season definitions by rental location ID (optional)",
                      "required": false,
                      "schema": {
                        "type": "integer",
                        "format": "int64",
                        "minimum": 1,
                        "nullable": true
                      },
                      "example": 1
                    }
                  ],
                  "responses": {
                    "200": {
                      "description": "successful operation",
                      "content": {
                        "application/json": {
                          "schema": {
                            "type": "array",
                            "items": {
                              "$ref": "#/components/schemas/SeasonDefinition"
                            }
                          }
                        }
                      }
                    },
                    "400": {
                      "description": "Bad request - invalid parameters",
                      "content": {
                        "application/json": {
                          "schema": {
                            "type": "object",
                            "properties": {
                              "error": {
                                "type": "string",
                                "description": "Error message"
                              }
                            }
                          }
                        }
                      }
                    },
                    "422": {
                      "description": "Validation error",
                      "content": {
                        "application/json": {
                          "schema": {
                            "type": "object",
                            "properties": {
                              "errors": {
                                "type": "object",
                                "description": "Validation errors by field"
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              },
              "/api/season-definitions": {
                "get": {
                  "summary": "List season definitions (authenticated endpoint)",
                  "description": "Returns a list of season definitions filtered by rate type and rental location. This endpoint requires authentication and both rate_type_id and rental_location_id are mandatory.",
                  "operationId": "listSeasonDefinitions",
                  "tags": ["Season Definitions"],
                  "parameters": [
                    {
                      "name": "rate_type_id",
                      "in": "query",
                      "description": "Rate type ID to filter season definitions (required)",
                      "required": true,
                      "schema": {
                        "type": "integer",
                        "format": "int64",
                        "minimum": 1
                      },
                      "example": 1
                    },
                    {
                      "name": "rental_location_id",
                      "in": "query",
                      "description": "Rental location ID to filter season definitions (required)",
                      "required": true,
                      "schema": {
                        "type": "integer",
                        "format": "int64",
                        "minimum": 1
                      },
                      "example": 1
                    }
                  ],
                  "responses": {
                    "200": {
                      "description": "successful operation",
                      "content": {
                        "application/json": {
                          "schema": {
                            "type": "array",
                            "items": {
                              "$ref": "#/components/schemas/SeasonDefinition"
                            }
                          }
                        }
                      }
                    },
                    "401": {
                      "description": "Unauthorized",
                      "content": {
                        "application/json": {
                          "schema": {
                            "type": "object",
                            "properties": {
                              "error": {
                                "type": "string",
                                "description": "Error message"
                              }
                            }
                          }
                        }
                      }
                    },
                    "400": {
                      "description": "Bad request - rate_type_id and rental_location_id are required",
                      "content": {
                        "application/json": {
                          "schema": {
                            "type": "object",
                            "properties": {
                              "error": {
                                "type": "string",
                                "description": "Error message"
                              }
                            }
                          }
                        }
                      }
                    },
                    "422": {
                      "description": "Validation error",
                      "content": {
                        "application/json": {
                          "schema": {
                            "type": "object",
                            "properties": {
                              "errors": {
                                "type": "object",
                                "description": "Validation errors by field"
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              },
              "/api/seasons": {
                "get": {
                  "summary": "List all seasons",
                  "description": "Returns a list of all seasons ordered by name",
                  "operationId": "listSeasons",
                  "tags": ["Seasons"],
                  "responses": {
                    "200": {
                      "description": "successful operation",
                      "content": {
                        "application/json": {
                          "schema": {
                            "type": "array",
                            "items": {
                              "$ref": "#/components/schemas/Season"
                            }
                          }
                        }
                      }
                    },
                    "401": {
                      "description": "Unauthorized",
                      "content": {
                        "application/json": {
                          "schema": {
                            "type": "object",
                            "properties": {
                              "error": {
                                "type": "string",
                                "description": "Error message"
                              }
                            }
                          }
                        }
                      }
                    },
                    "400": {
                      "description": "Bad request",
                      "content": {
                        "application/json": {
                          "schema": {
                            "type": "object",
                            "properties": {
                              "error": {
                                "type": "string",
                                "description": "Error message"
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              },
              "/api/seasons-by-season-definition": {
                "get": {
                  "summary": "List seasons by season definition",
                  "description": "Returns seasons filtered by season definition ID",
                  "operationId": "listSeasonsBySeasonDefinition",
                  "tags": ["Seasons"],
                  "parameters": [
                    {
                      "name": "season_definition_id",
                      "in": "query",
                      "description": "Season definition ID to filter seasons",
                      "required": true,
                      "schema": {
                        "type": "integer",
                        "format": "int64",
                        "minimum": 1
                      }
                    }
                  ],
                  "responses": {
                    "200": {
                      "description": "successful operation",
                      "content": {
                        "application/json": {
                          "schema": {
                            "type": "array",
                            "items": {
                              "$ref": "#/components/schemas/Season"
                            }
                          }
                        }
                      }
                    },
                    "401": {
                      "description": "Unauthorized",
                      "content": {
                        "application/json": {
                          "schema": {
                            "type": "object",
                            "properties": {
                              "error": {
                                "type": "string",
                                "description": "Error message"
                              }
                            }
                          }
                        }
                      }
                    },
                    "400": {
                      "description": "Bad request - season_definition_id is required",
                      "content": {
                        "application/json": {
                          "schema": {
                            "type": "object",
                            "properties": {
                              "error": {
                                "type": "string",
                                "description": "Error message"
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              },
              "/api/open-pricing": {
                "get": {
                  "summary": "List price definitions with optional filters",
                  "description": "Returns a list of price definitions with optional filtering capabilities. All parameters are optional.",
                  "operationId": "listOpenPricing",
                  "tags": ["Pricing"],
                  "parameters": [
                    {
                      "name": "rental_location_id",
                      "in": "query",
                      "description": "Rental location ID to filter price definitions. Optional parameter",
                      "required": false,
                      "schema": {
                        "type": "integer"
                      },
                      "example": 1
                    },
                    {
                      "name": "season_definition_id",
                      "in": "query",
                      "description": "Season definition ID to filter price definitions. Optional parameter",
                      "required": false,
                      "schema": {
                        "type": "integer"
                      },
                      "example": 1
                    },
                    {
                      "name": "rate_type_id",
                      "in": "query",
                      "description": "Rate type ID to filter price definitions. Optional parameter",
                      "required": false,
                      "schema": {
                        "type": "integer"
                      },
                      "example": 1
                    },
                    {
                      "name": "season_id",
                      "in": "query",
                      "description": "Season ID to filter price definitions. Optional parameter",
                      "required": false,
                      "schema": {
                        "type": "integer"
                      },
                      "example": 1
                    },
                    {
                      "name": "unit",
                      "in": "query",
                      "description": "Time unit to filter prices. Optional parameter. 1 = meses, 2 = días, 3 = horas, 4 = minutos",
                      "required": false,
                      "schema": {
                        "type": "integer",
                        "minimum": 1,
                        "maximum": 4,
                        "description": "Time unit for filtering prices: 1=meses, 2=días, 3=horas, 4=minutos"
                      },
                      "example": 2
                    },
                    {
                      "name": "page",
                      "in": "query",
                      "description": "Page number for pagination. Optional parameter",
                      "required": false,
                      "schema": {
                        "type": "integer",
                        "minimum": 1,
                        "default": 1
                      },
                      "example": 1
                    },
                    {
                      "name": "per_page",
                      "in": "query",
                      "description": "Number of results per page. Optional parameter (max 100)",
                      "required": false,
                      "schema": {
                        "type": "integer",
                        "minimum": 1,
                        "maximum": 100,
                        "default": 10
                      },
                      "example": 10
                    }
                  ],
                  "responses": {
                    "200": {
                      "description": "successful operation",
                      "content": {
                        "application/json": {
                          "schema": {
                            "type": "object",
                            "properties": {
                              "page": {
                                "type": "integer",
                                "description": "Current page number"
                              },
                              "per_page": {
                                "type": "integer",
                                "description": "Number of items per page"
                              },
                              "last_page": {
                                "type": "integer",
                                "description": "Last page number"
                              },
                              "total": {
                                "type": "integer",
                                "description": "Total number of items"
                              },
                              "data": {
                                "type": "array",
                                "items": {
                                  "$ref": "#/components/schemas/PriceDefinitionWithPrices"
                                }
                              }
                            }
                          }
                        }
                      }
                    },
                    "422": {
                      "description": "Validation error",
                      "content": {
                        "application/json": {
                          "schema": {
                            "type": "object",
                            "properties": {
                              "errors": {
                                "type": "object",
                                "description": "Validation errors by field"
                              }
                            }
                          }
                        }
                      }
                    },
                    "500": {
                      "description": "Internal server error",
                      "content": {
                        "application/json": {
                          "schema": {
                            "type": "object",
                            "properties": {
                              "error": {
                                "type": "string",
                                "description": "Error message"
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              },
              "/api/pricing": {
                "get": {
                  "summary": "List price definitions with required filters",
                  "description": "Returns a list of price definitions with mandatory filtering capabilities. All parameters are required.",
                  "operationId": "listPricing",
                  "tags": ["Pricing"],
                  "parameters": [
                    {
                      "name": "rental_location_id",
                      "in": "query",
                      "description": "Rental location ID to filter price definitions. Required parameter",
                      "required": true,
                      "schema": {
                        "type": "integer"
                      },
                      "example": 1
                    },
                    {
                      "name": "season_definition_id",
                      "in": "query",
                      "description": "Season definition ID to filter price definitions. Required parameter",
                      "required": true,
                      "schema": {
                        "type": "integer"
                      },
                      "example": 1
                    },
                    {
                      "name": "rate_type_id",
                      "in": "query",
                      "description": "Rate type ID to filter price definitions. Required parameter",
                      "required": true,
                      "schema": {
                        "type": "integer"
                      },
                      "example": 1
                    },
                    {
                      "name": "season_id",
                      "in": "query",
                      "description": "Season ID to filter price definitions. Required parameter",
                      "required": true,
                      "schema": {
                        "type": "integer"
                      },
                      "example": 1
                    },
                    {
                      "name": "unit",
                      "in": "query",
                      "description": "Time unit to filter prices. Required parameter. 1 = meses, 2 = días, 3 = horas, 4 = minutos",
                      "required": true,
                      "schema": {
                        "type": "integer",
                        "minimum": 1,
                        "maximum": 4,
                        "description": "Time unit for filtering prices: 1=meses, 2=días, 3=horas, 4=minutos"
                      },
                      "example": 2
                    },
                    {
                      "name": "page",
                      "in": "query",
                      "description": "Page number for pagination. Optional parameter",
                      "required": false,
                      "schema": {
                        "type": "integer",
                        "minimum": 1,
                        "default": 1
                      },
                      "example": 1
                    },
                    {
                      "name": "per_page",
                      "in": "query",
                      "description": "Number of results per page. Optional parameter (max 100)",
                      "required": false,
                      "schema": {
                        "type": "integer",
                        "minimum": 1,
                        "maximum": 100,
                        "default": 10
                      },
                      "example": 10
                    }
                  ],
                  "responses": {
                    "200": {
                      "description": "successful operation",
                      "content": {
                        "application/json": {
                          "schema": {
                            "type": "object",
                            "properties": {
                              "page": {
                                "type": "integer",
                                "description": "Current page number"
                              },
                              "per_page": {
                                "type": "integer",
                                "description": "Number of items per page"
                              },
                              "last_page": {
                                "type": "integer",
                                "description": "Last page number"
                              },
                              "total": {
                                "type": "integer",
                                "description": "Total number of items"
                              },
                              "data": {
                                "type": "array",
                                "items": {
                                  "$ref": "#/components/schemas/PriceDefinitionWithPrices"
                                }
                              }
                            }
                          }
                        }
                      }
                    },
                    "422": {
                      "description": "Validation error",
                      "content": {
                        "application/json": {
                          "schema": {
                            "type": "object",
                            "properties": {
                              "errors": {
                                "type": "object",
                                "description": "Validation errors by field"
                              }
                            }
                          }
                        }
                      }
                    },
                    "500": {
                      "description": "Internal server error",
                      "content": {
                        "application/json": {
                          "schema": {
                            "type": "object",
                            "properties": {
                              "error": {
                                "type": "string",
                                "description": "Error message"
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              },
              "/api/export/prices.csv": {
                "get": {
                  "summary": "Export all prices to CSV",
                  "description": "Downloads a CSV file containing all price data with category, rental location, rate type, season, and pricing information",
                  "operationId": "exportPricesCsv",
                  "tags": ["Export"],
                  "responses": {
                    "200": {
                      "description": "CSV file download",
                      "content": {
                        "text/csv": {
                          "schema": {
                            "type": "string",
                            "format": "binary"
                          }
                        }
                      },
                      "headers": {
                        "Content-Disposition": {
                          "description": "Attachment filename",
                          "schema": {
                            "type": "string",
                            "example": "attachment; filename=\"precios_export.csv\""
                          }
                        }
                      }
                    },
                    "500": {
                      "description": "Internal server error",
                      "content": {
                        "text/plain": {
                          "schema": {
                            "type": "string",
                            "description": "Error message"
                          }
                        }
                      }
                    }
                  }
                }
              },
              "/api/import/prices": {
                "post": {
                  "summary": "Import prices from CSV",
                  "description": "Uploads a CSV file to import price data. The CSV should contain category_code, rental_location_name, rate_type_name, season_name, time_measurement, units, and optional price, included_km, extra_km_price columns.",
                  "operationId": "importPrices",
                  "tags": ["Import"],
                  "requestBody": {
                    "required": true,
                    "content": {
                      "multipart/form-data": {
                        "schema": {
                          "type": "object",
                          "properties": {
                            "file": {
                              "type": "string",
                              "format": "binary",
                              "description": "CSV file containing price data"
                            }
                          },
                          "required": ["file"]
                        }
                      }
                    }
                  },
                  "responses": {
                    "200": {
                      "description": "Import successful",
                      "content": {
                        "application/json": {
                          "schema": {
                            "type": "object",
                            "properties": {
                              "status": {
                                "type": "string",
                                "description": "Import status",
                                "example": "success"
                              },
                              "message": {
                                "type": "string",
                                "description": "Success message",
                                "example": "Importación completada"
                              }
                            },
                            "required": ["status", "message"]
                          }
                        }
                      }
                    },
                    "400": {
                      "description": "Bad request - missing file",
                      "content": {
                        "text/plain": {
                          "schema": {
                            "type": "string",
                            "description": "Error message",
                            "example": "Archivo requerido"
                          }
                        }
                      }
                    },
                    "422": {
                      "description": "Validation error",
                      "content": {
                        "application/json": {
                          "schema": {
                            "type": "object",
                            "properties": {
                              "status": {
                                "type": "string",
                                "description": "Error status",
                                "example": "error"
                              },
                              "message": {
                                "type": "string",
                                "description": "Error message"
                              }
                            }
                          }
                        }
                      }
                    },
                    "500": {
                      "description": "Internal server error",
                      "content": {
                        "application/json": {
                          "schema": {
                            "type": "object",
                            "properties": {
                              "status": {
                                "type": "string",
                                "description": "Error status",
                                "example": "error"
                              },
                              "message": {
                                "type": "string",
                                "description": "Error message"
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            },
            "components": {
              "schemas": {
                "RentalLocation": {
                  "type": "object",
                  "properties": {
                    "id": {
                      "type": "integer",
                      "description": "Unique identifier for the rental location",
                      "format": "int64"
                    },
                    "name": {
                      "type": "string",
                      "description": "Name of the rental location",
                      "maxLength": 255
                    }
                  },
                  "required": ["id", "name"]
                },
                "RateType": {
                  "type": "object",
                  "properties": {
                    "id": {
                      "type": "integer",
                      "description": "Unique identifier for the rate type",
                      "format": "int64"
                    },
                    "name": {
                      "type": "string",
                      "description": "Name of the rate type",
                      "maxLength": 255
                    }
                  },
                  "required": ["id", "name"]
                },
                "SeasonDefinition": {
                  "type": "object",
                  "properties": {
                    "id": {
                      "type": "integer",
                      "description": "Unique identifier for the season definition",
                      "format": "int64"
                    },
                    "name": {
                      "type": "string",
                      "description": "Name of the season definition",
                      "maxLength": 255
                    }
                  },
                  "required": ["id", "name"]
                },
                "Season": {
                  "type": "object",
                  "properties": {
                    "id": {
                      "type": "integer",
                      "description": "Unique identifier for the season",
                      "format": "int64"
                    },
                    "name": {
                      "type": "string",
                      "description": "Name of the season",
                      "maxLength": 255
                    },
                    "season_definition_id": {
                      "type": "integer",
                      "description": "ID of the associated season definition",
                      "format": "int64"
                    }
                  },
                  "required": ["id", "name", "season_definition_id"]
                },
                "PriceDefinition": {
                  "type": "object",
                  "properties": {
                    "id": {
                      "type": "integer",
                      "description": "Unique identifier for the price definition",
                      "format": "int64"
                    },
                    "name": {
                      "type": "string",
                      "description": "Name of the price definition",
                      "maxLength": 255
                    },
                    "type": {
                      "type": "string",
                      "description": "Type of price definition",
                      "enum": ["season", "no_season"]
                    },
                    "rental_location_id": {
                      "type": "integer",
                      "description": "ID of the associated rental location",
                      "format": "int64"
                    },
                    "rate_type_id": {
                      "type": "integer",
                      "description": "ID of the associated rate type",
                      "format": "int64"
                    },
                    "season_definition_id": {
                      "type": "integer",
                      "description": "ID of the associated season definition",
                      "format": "int64",
                      "nullable": true
                    },
                    "excess": {
                      "type": "number",
                      "description": "Excess amount",
                      "format": "decimal"
                    },
                    "deposit": {
                      "type": "number",
                      "description": "Deposit amount",
                      "format": "decimal"
                    }
                  },
                  "required": ["id", "name", "type", "rental_location_id", "rate_type_id"]
                },
                "PriceDefinitionWithPrices": {
                  "type": "object",
                  "properties": {
                    "rental_location_name": {
                      "type": "string",
                      "description": "Name of the rental location"
                    },
                    "rate_type_name": {
                      "type": "string",
                      "description": "Name of the rate type"
                    },
                    "category_code": {
                      "type": "string",
                      "description": "Category code"
                    },
                    "category_name": {
                      "type": "string",
                      "description": "Category name"
                    },
                    "price_definition_id": {
                      "type": "integer",
                      "description": "Price definition ID"
                    },
                    "prices": {
                      "type": "array",
                      "description": "Array of prices for this price definition",
                      "items": {
                        "type": "object",
                        "properties": {
                          "season_id": {
                            "type": "integer",
                            "description": "Season ID"
                          },
                          "units": {
                            "type": "integer",
                            "description": "Number of units"
                          },
                          "time_measurement": {
                            "type": "integer",
                            "description": "Time measurement code"
                          },
                          "price": {
                            "type": "number",
                            "description": "Price value"
                          }
                        }
                      }
                    }
                  },
                  "required": ["rental_location_name", "rate_type_name", "category_code", "category_name", "price_definition_id", "prices"]
                }
              }
            }
          }.to_json
        end

      end

    end
  end
end