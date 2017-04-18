# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require 'simplecov'
SimpleCov.start

require File.expand_path("../../spec/dummy/config/environment.rb", __FILE__)
ActiveRecord::Migrator.migrations_paths = [File.expand_path("../../spec/dummy/db/migrate", __FILE__)]

require 'wor/authentication'
require 'rspec/rails'

RSpec.shared_context 'With session' do
  let!(:access_data) { AuthenticationController.new.generate_access_token({}) }
  let!(:access_token) { access_data[:token] }
  let!(:renew_id) { access_data[:renew_id] }

  before(:each) do
    request.headers['Authorization'] = access_token
  end
end
