module Tokenable
  module Strategies
    module Devise
      extend ActiveSupport::Concern

      class_methods do
        # @return [string, nil] Returns user_id + revocation key (not used yet)
        def from_params(params)
          email, password = parse_auth_params(params)

          user = User.find_by(email: email)
          return nil unless user

          return nil unless user.valid_password?(password)

          [user.id, nil]
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
