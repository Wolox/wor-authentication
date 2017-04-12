# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require 'simplecov'
SimpleCov.start

require File.expand_path("../../spec/dummy/config/environment.rb", __FILE__)
ActiveRecord::Migrator.migrations_paths = [File.expand_path("../../spec/dummy/db/migrate", __FILE__)]

require 'wor/authentication'
require 'rspec/rails'
