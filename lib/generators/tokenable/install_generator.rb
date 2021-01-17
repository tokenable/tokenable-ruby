# frozen_string_literal: true

module Tokenable
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __dir__)

      def install
        template 'tokenable.rb.erb', 'config/initializers/tokenable.rb'
        route "mount Tokenable::Engine => '/api/auth'"
      end
    end
  end
end
