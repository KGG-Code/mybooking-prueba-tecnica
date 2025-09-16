# DataMapper dependencies
require 'stringio'
require 'logger'

# Bundle dependencies
require 'bundler/setup'
require 'bundler'
Bundler.require

# Zeitwerk
require './config/zeitwerk'

# Load environment variables
require 'dotenv'
Dotenv.load

# Database configuration
require 'dm-core'
DataMapper.logger = ::Logger.new($stdout)
DataMapper.logger.level = :debug
DataMapper.setup(:default, ENV['DATABASE_URL'])
DataMapper::Model.raise_on_save_failure = true
DataMapper.finalize

# Active support
require 'active_support'
require 'active_support/time'
require 'active_support/core_ext'
ENV['TZ'] = 'UTC'

# Base classes
require_relative '../lib/base_repository'
require_relative '../lib/base_serializer'
require_relative '../lib/query'
require_relative '../lib/transaction'

# Validation classes
require_relative '../app/validation/validator'
require_relative '../app/validation/dry_validator'

# Middlewares
require_relative "../app/middlewares/error_handler"