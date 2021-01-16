# frozen_string_literal: true

module Tokenable
  module Strategies
    module SecurePassword
      extend ActiveSupport::Concern

      class_methods do
        # @return [string, nil] Returns user_id + revocation key (not used yet)
        def from_params(params)
          email, password = parse_auth_params(params)

          user = User.find_by(email: email)
          return nil unless user

          return nil unless user.authenticate(password)

          user
        end

        private

        def parse_auth_params(params)
          [
            params.require(:email),
            params.require(:password),
          ]
        end
      end
    end
  end
end
