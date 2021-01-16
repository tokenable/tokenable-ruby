module Tokenable
  class TokensController < ::ActionController::API
    def create
      email, password = parse_auth_params

      # Attempt to find the user
      user = User.find_by(email: email)
      raise Tokenable::Unauthorized unless user

      # Ensure password matches
      raise Tokenable::Unauthorized unless user.authenticate(password)

      jwt_data = {
        user_id: user.id,
      }
      jwt_token = JWT.encode(jwt_data, jwt_secret, 'HS256')
      data = {
        user_id: user.id,
        token: jwt_token,
      }

      render json: { data: data }, status: 201
    end

    protected

    def parse_auth_params
      [
        params.require(:email),
        params.require(:password),
      ]
    end

    def jwt_secret
      Rails.application.secret_key_base
    end
  end
end
