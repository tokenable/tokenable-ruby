# frozen_string_literal: true

require 'rails/generators/active_record'

module Tokenable
  module Generators
    class InstallGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('../templates', __dir__)
      class_option :strategy, type: :string

      def install_config
        template 'tokenable.rb.erb', 'config/initializers/tokenable.rb'
      end

      def setup_route
        route "mount Tokenable::Engine => '/api/auth'"
      end

      def setup_strategy
        unless options.strategy
          say_status :skip, 'strategy (none provided)', :yellow
          return
        end

        if options.strategy.in?(list_of_strategies)
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

      def list_of_strategies
        Dir.entries(File.expand_path('../../tokenable/strategies', __dir__))
           .reject { |f| File.directory?(f) }
           .map { |f| File.basename(f, File.extname(f)) }
           .compact
      end
    end
  end
end
