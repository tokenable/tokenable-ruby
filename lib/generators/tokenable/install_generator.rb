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
        if options.strategy.in?(%w[devise secure_password])
          strategy = {
            devise: 'Devise',
            secure_password: 'SecurePassword',
          }[options.strategy.to_sym]

          inject_into_file "app/models/#{file_name}.rb", "  include Tokenable::Strategies::#{strategy}\n", after: " < ApplicationRecord\n"
        else
          say 'Stargery not found'
        end
      end
    end
  end
end
