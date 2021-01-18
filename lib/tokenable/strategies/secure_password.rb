# frozen_string_literal: true

module Tokenable
  module Strategies
    module SecurePassword
      extend ActiveSupport::Concern

      class_methods do
        def from_tokenable_params(params)
          email, password = parse_auth_params(params)

          user = Tokenable::Config.user_class.find_by(email: email)
          return nil unless user

          return nil unless user.authenticate(password)

          user
        end

        private

        def parse_auth_params(params)
          [
            params[:email],
            params[:password],
          ]
        end
      end
    end
  end
end
