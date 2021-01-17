# frozen_string_literal: true

require 'rails/generators/active_record'

module Tokenable
  module Generators
    class VerifierGenerator < ActiveRecord::Generators::Base
      source_root File.expand_path('../templates', __dir__)

      def generate_model
        invoke 'active_record:model', [name], migration: false unless model_exists? && behavior == :invoke
      end

      def add_to_model
        model_path = "app/models/#{file_name}.rb"
        already_injected = File.open(File.join(destination_root, model_path)).grep(/Tokenable::Verifier/).any?

        if already_injected
          say_status :skip, 'verifier is already in this model', :yellow
        else
          inject_into_file "app/models/#{file_name}.rb", "  include Tokenable::Verifier\n", after: " < ApplicationRecord\n"
        end
      end

      def add_migration
        migration_template 'verifier_migration.rb.erb', "db/migrate/add_tokenable_verifier_to_#{table_name}.rb"
      end

      private

      def model_exists?
        File.exist?(File.join(destination_root, 'app/models'))
      end

      def migration_version
        "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]" if Rails::VERSION::MAJOR >= 5
      end
    end
  end
end
