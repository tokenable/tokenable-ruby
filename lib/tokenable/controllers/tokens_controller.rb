# frozen_string_literal: true

module Tokenable
  class TokensController < ::ActionController::API
    include Authable

    def create
      user = Tokenable::Config.user_class.from_tokenable_params(params)
      raise Tokenable::Unauthorized unless user

      response = {
        data: {
          token: token_from_user(user),
          user_id: user.id,
        },
      }

      render json: response, status: 201
    end
  end
end
