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

      def setup_statergy

        strategies = Dir.entries(File.expand_path('../../tokenable/strategies', __dir__))
                        .reject{|f| File.directory?(f) }
                        .map{|f| File.basename(f, File.extname(f)) }

        if options.strategy.in?(strategies)
          strategy_class = options.strategy.classify

          inject_into_file "app/models/#{file_name}.rb", "  include Tokenable::Strategies::#{strategy_class}\n", after: " < ApplicationRecord\n"
        else
          say "#{options.strategy} => #{strategies}"
          say 'Stargery not found'
        end
      end
    end
  end
end
