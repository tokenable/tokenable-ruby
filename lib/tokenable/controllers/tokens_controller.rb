# frozen_string_literal: true

module Tokenable
  class TokensController < ::ActionController::API
    include Authable

    def create
      user_id, = User.from_params(params)
      raise Tokenable::Unauthorized unless user_id

      token = token_from_user(user_id)
      render json: { data: token }, status: 201
    end
  end
end
