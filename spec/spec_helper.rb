# frozen_string_literal: true

require 'simplecov'
SimpleCov.start 'rails' do
  add_filter 'spec/dummy'
end

ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../spec/dummy/config/environment.rb', __dir__)
ENV['RAILS_ROOT'] ||= "#{File.dirname(__FILE__)}../../../spec/dummy"

require 'rspec/rails'

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

require 'database_cleaner'

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  # Keep track of the original config class variables, as we need to reset them after each spec.
  config_defaults = Tokenable::Config.class_variables.map do |variable|
    [variable, Tokenable::Config.class_variable_get(variable)]
  end.to_h

  # Reset Tokenable::Config to it's original state after each spec
  config.after do |_example|
    config_defaults.each do |key, value|
      Tokenable::Config.class_variable_set(key, value)
    end
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.order = :random
end
