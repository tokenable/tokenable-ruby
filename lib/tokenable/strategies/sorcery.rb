# frozen_string_literal: true

module Tokenable
  module Strategies
    module Sorcery
      extend ActiveSupport::Concern

      class_methods do
        def from_tokenable_params(params)
          email, password = parse_auth_params(params)

          user = Tokenable::Config.user_class.find_by(email: email)
          return nil unless user

          return nil unless user.valid_password?(password)

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
