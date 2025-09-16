# MyBooking - Guía de Instalación

## Prerequisites

- Ruby 3.3.0
- MySQL or MariaDB
- Bundler gem

## Database

The file prueba_tecnica.sql is a dump of the db to be used.

## Environment Configuration

Create an `.env` file in the `src` directory:

```ruby
COOKIE_SECRET="your-secret-key-here"
DATABASE_URL="mysql://username:password@localhost:3306/prueba_tecnica?encoding=UTF-8-MB4"
TEST_DATABASE_URL="mysql://username:password@localhost:3306/prueba_tecnica_test?encoding=UTF-8-MB4"
```

## Installation

```bash
bundle install
```

## Running the Application

```bash
bundle exec rackup
```

Open your browser and check:

- http://localhost:9292/pricing - Pricing management form

## API Endpoints

### Master Data
- `GET /api/rental-locations` - List all rental locations
- `GET /api/open-rate-types` - List rate types (open endpoint)
- `GET /api/rate-types` - List rate types (requires rental_location_id)
- `GET /api/open-season-definitions` - List season definitions (open endpoint)
- `GET /api/season-definitions` - List season definitions (requires rate_type_id and rental_location_id)
- `GET /api/open-seasons` - List seasons (open endpoint)
- `GET /api/seasons` - List seasons (requires season_definition_id)

### Pricing
- `GET /api/open-pricing` - List prices with optional filters
- `GET /api/pricing` - List prices with required filters
- `POST /api/import/prices` - Import prices from CSV
- `GET /api/export/prices.csv` - Export prices to CSV

## Swagger Documentation

The API includes interactive Swagger documentation:

- **Swagger UI**: http://localhost:9292/swagger
- **Swagger JSON**: http://localhost:9292/swagger.json

The Swagger UI provides:
- Complete API documentation
- Interactive endpoint testing
- Request/response examples
- Parameter descriptions

### Architectural Pattern

**Controller → Use Case → Repository/Service**

- **Controllers**: Handle HTTP requests/responses and input validation
- **Use Cases**: Encapsulate specific business logic and orchestration
- **Repositories**: Abstract data access and persistence operations
- **Services**: Implement complex business operations and cross-cutting concerns

### Design Principles

#### Composition over Inheritance
The architecture favors **composition over inheritance** to achieve:
- **Maintainability**: Easier code maintenance and modification
- **Scalability**: Simplified feature extension and system growth
- **Testability**: Smaller, focused components with clear boundaries
- **Flexibility**: Behavior modification without altering class hierarchies

#### Error Handling System
A **comprehensive error handling system** has been implemented featuring:
- **Specific error classes**: `ValidationError`, `NotFoundError`, `UnauthorizedError`, `ExportError`
- **Error middleware**: Centralized error interception and processing
- **Structured responses**: Consistent error format across API endpoints
- **Centralized logging**: Error tracking for debugging and monitoring

### Layer Structure

```
Controller Layer    → HTTP handling, input validation, response formatting
Use Case Layer      → Business logic orchestration, workflow coordination
Service Layer       → Complex operations, external integrations, algorithms
Repository Layer    → Data access abstraction, persistence operations
Model Layer         → Domain entities, business rules, data validation
```

This architecture ensures **separation of concerns**, **loose coupling**, and **high cohesion**, facilitating system maintenance and evolution while supporting enterprise-grade scalability and reliability.

## Running Tests

```bash
bundle exec rspec spec
```

Run specific test types:

```bash
bundle exec rspec spec/integration
bundle exec rspec spec/unit
```

## Import/Export

### Import CSV Format

Required columns:
- `category_code` - Vehicle category (A, B, C, A1)
- `rental_location_name` - Location name
- `rate_type_name` - Rate type
- `season_definition_name` - Season group (optional)
- `season_name` - Season name (optional)
- `time_measurement` - Time unit (días, meses, horas, minutos)
- `units` - Number of units
- `price` - Price value
- `included_km` - Included kilometers (optional)
- `extra_km_price` - Extra km price (optional)

### Export

Download all prices via `/api/export/prices` endpoint.

## Project Structure

```
src/
├── app/
│   ├── adapters/          # File readers
│   ├── controller/        # Sinatra controllers
│   ├── model/            # DataMapper models
│   ├── repository/        # Data repositories
│   ├── service/          # Business logic
│   ├── use_case/         # Use cases
│   ├── validation/       # Validations
│   └── views/           # Templates
├── config/              # Configuration
├── lib/                 # Base libraries
├── spec/                # Tests
└── Gemfile              # Dependencies
```