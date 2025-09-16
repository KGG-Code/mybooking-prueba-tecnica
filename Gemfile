source 'https://rubygems.org'
ruby '3.3.0'

gem 'zeitwerk', '~> 2.6'

gem "sinatra", "~>3.2"
gem "sinatra-contrib", "~>3.2", require: false
gem "puma"

gem "activesupport", '~> 6.1'

gem "data_mapper", "1.2.0"
gem "dm-core", git: "https://github.com/mybooking-es/dm-core"
gem "dm-aggregates", git: "https://github.com/mybooking-es/dm-aggregates"
gem "dm-constraints", git: "https://github.com/mybooking-es/dm-constraints"
gem "dm-do-adapter", git: "https://github.com/mybooking-es/dm-do-adapter"
gem "dm-migrations", git: "https://github.com/mybooking-es/dm-migrations"
gem "dm-mysql-adapter", git: "https://github.com/mybooking-es/dm-mysql-adapter"
gem "dm-transactions", git: "https://github.com/mybooking-es/dm-transactions"
gem "data_objects", git: "https://github.com/mybooking-es/data_objects"
gem "do_mysql","0.10.17", git: 'https://github.com/mybooking-es/do_mysql'
gem "dm-types", git: "https://github.com/mybooking-es/dm-types"
gem "dm-serializer", git: "https://github.com/mybooking-es/dm-serializer"
gem "dm-active_model", git: "https://github.com/mybooking-es/dm-active_model"
gem "dm-validations"
gem "dm-observer"

# Compatibility with Ruby 3.4.0
gem 'csv'
gem 'mutex_m'

# Excel file handling
gem 'roo', '~> 2.10'

group :development do
  gem "dotenv"
  gem 'rspec'
  gem 'rspec-its'
  gem 'factory_bot'
  gem 'database_cleaner-data_mapper'
  gem 'timecop'
  gem 'dm-rspec'
  gem 'webmock' # Para simular peticiones HTTP en tests
  gem 'sqlite3', '2.4.1'
  gem 'dm-sqlite-adapter', git: "https://github.com/mybooking-es/dm-sqlite-adapter"
  gem "do_sqlite3","0.10.17", git: 'https://github.com/mybooking-es/do_sqlite3'
  gem 'rack-test'
  gem 'debug'
end
