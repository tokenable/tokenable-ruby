module Tokenable
  class TokensController < ::ActionController::API
    include Authable

    def create
      user_id, _ = User.from_params(params)
      raise Tokenable::Unauthorized unless user_id

      jwt_data = {
        user_id: user_id,
      }
      jwt_token = JWT.encode(jwt_data, jwt_secret, 'HS256')
      data = {
        user_id: user_id,
        token: jwt_token,
      }

      render json: { data: data }, status: 201
    end
  end
end
