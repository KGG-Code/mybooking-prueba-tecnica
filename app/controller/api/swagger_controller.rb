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
              "/api/rate-types": {
                "get": {
                  "summary": "List rate types",
                  "description": "Returns a list of rate types with optional rental location filter",
                  "operationId": "listRateTypes",
                  "tags": ["Rate Types"],
                  "parameters": [
                    {
                      "name": "rental_location_id",
                      "in": "query",
                      "description": "Filter rate types by rental location ID",
                      "required": false,
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
              "/api/rate-types-by-rental-location": {
                "get": {
                  "summary": "List rate types by rental location",
                  "description": "Returns a list of rate types filtered by rental location ID (required parameter)",
                  "operationId": "listRateTypesByRentalLocation",
                  "tags": ["Rate Types"],
                  "parameters": [
                    {
                      "name": "rental_location_id",
                      "in": "query",
                      "description": "Rental location ID to filter rate types",
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
                      "description": "Bad request - rental_location_id is required or invalid",
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
              "/api/season-definitions": {
                "get": {
                  "summary": "List all season definitions",
                  "description": "Returns a list of all season definitions ordered by name",
                  "operationId": "listSeasonDefinitions",
                  "tags": ["Season Definitions"],
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
              "/api/season-definitions-by-rate-type": {
                "get": {
                  "summary": "List season definitions by rate type and rental location",
                  "description": "Returns season definitions filtered by rate type and rental location based on price definitions",
                  "operationId": "listSeasonDefinitionsByRateType",
                  "tags": ["Season Definitions"],
                  "parameters": [
                    {
                      "name": "rate_type_id",
                      "in": "query",
                      "description": "Rate type ID to filter season definitions",
                      "required": true,
                      "schema": {
                        "type": "integer",
                        "format": "int64",
                        "minimum": 1
                      }
                    },
                    {
                      "name": "rental_location_id",
                      "in": "query",
                      "description": "Rental location ID to filter season definitions",
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
              "/api/pricing": {
                "get": {
                  "summary": "List price definitions with optional filters",
                  "description": "Returns a list of price definitions with optional filtering capabilities",
                  "operationId": "listPricing",
                  "tags": ["Pricing"],
                  "parameters": [
                    {
                      "name": "season_definition_id",
                      "in": "query",
                      "description": "Season definition ID to filter price definitions. Optional parameter",
                      "required": false,
                      "schema": {
                        "type": "string",
                        "description": "Integer ID or 'null' string"
                      },
                      "example": "1"
                    },
                    {
                      "name": "rate_type_id",
                      "in": "query",
                      "description": "Rate type ID to filter price definitions. Optional parameter",
                      "required": false,
                      "schema": {
                        "type": "string",
                        "description": "Integer ID or 'null' string"
                      },
                      "example": "1"
                    },
                    {
                      "name": "season_id",
                      "in": "query",
                      "description": "Season ID to filter price definitions. Optional parameter",
                      "required": false,
                      "schema": {
                        "type": "string",
                        "description": "Integer ID or 'null' string"
                      },
                      "example": "1"
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
                            "type": "array",
                            "items": {
                              "$ref": "#/components/schemas/PriceDefinition"
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
              "/api/filtered-pricing": {
                "get": {
                  "summary": "List price definitions with mandatory filters",
                  "description": "Returns price definitions filtered by mandatory season definition ID, with optional rate type ID and season ID filters",
                  "operationId": "listFilteredPricing",
                  "tags": ["Pricing"],
                  "parameters": [
                    {
                      "name": "season_definition_id",
                      "in": "query",
                      "description": "Season definition ID to filter price definitions. Pass 'null' to get price definitions without season definition",
                      "required": true,
                      "schema": {
                        "type": "string",
                        "description": "Integer ID or 'null' string"
                      },
                      "example": "1"
                    },
                    {
                      "name": "rate_type_id",
                      "in": "query",
                      "description": "Rate type ID to filter price definitions. Optional parameter",
                      "required": false,
                      "schema": {
                        "type": "string",
                        "description": "Integer ID or 'null' string"
                      },
                      "example": "1"
                    },
                    {
                      "name": "season_id",
                      "in": "query",
                      "description": "Season ID to filter price definitions. Optional parameter",
                      "required": false,
                      "schema": {
                        "type": "string",
                        "description": "Integer ID or 'null' string"
                      },
                      "example": "1"
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
                            "type": "array",
                            "items": {
                              "$ref": "#/components/schemas/PriceDefinition"
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
                  "required": ["id", "name", "type", "rate_type_id"]
                }
              }
            }
          }.to_json
        end

      end

    end
  end
end