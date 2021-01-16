module Tokenable
  class TokensController < ::ActionController::API
    include Authable

    def create
      email, password = parse_auth_params

      # Attempt to find the user
      user = User.select(:id, :password_digest).find_by(email: email)
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

    private

    def parse_auth_params
      [
        params.require(:email),
        params.require(:password),
      ]
    end
  end
end
