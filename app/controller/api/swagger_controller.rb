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
                }
              }
            }
          }.to_json
        end

      end

    end
  end
end