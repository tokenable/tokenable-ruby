# frozen_string_literal: true

require 'rails/generators/active_record'

module Tokenable
  module Generators
    class InstallGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('../templates', __dir__)
      class_option :strategy, type: :string

      def install_config
        template 'tokenable.rb.erb', 'config/initializers/tokenable.rb'
        template 'routes.rb.erb', 'config/routes.rb' unless routes_file_exists?
        route "mount Tokenable::Engine => '/api/auth'"
      end

      def setup_strategy
        unless options.strategy
          say_status :skip, 'strategy (none provided)', :yellow
          return
        end

        if options.strategy.in?(list_of_strategies)
          invoke 'active_record:model', [name], migration: false unless model_exists?

          strategy_class = options.strategy.classify
          model_path = "app/models/#{file_name}.rb"
          already_injected = File.open(File.join(destination_root, model_path)).grep(/Tokenable::Strategies/).any?

          if already_injected
            say_status :skip, 'a strategy is already in this model', :yellow
          else
            inject_into_file model_path, "  include Tokenable::Strategies::#{strategy_class}\n", after: " < ApplicationRecord\n"
          end
        else
          say_status :failure, "stargery not found (#{options.strategy}). Available: #{list_of_strategies.join(", ")}", :red
        end
      end

      private

      def model_exists?
        File.exist?(File.join(destination_root, "app/models/#{file_name}.rb"))
      end

      def routes_file_exists?
        File.exist?(File.join(destination_root, 'config/routes.rb'))
      end

      def list_of_strategies
        Dir.entries(File.expand_path('../../tokenable/strategies', __dir__))
           .reject { |f| File.directory?(f) }
           .map { |f| File.basename(f, File.extname(f)) }
           .compact
      end
    end
  end
end
