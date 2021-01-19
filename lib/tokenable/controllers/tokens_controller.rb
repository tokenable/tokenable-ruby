# frozen_string_literal: true

module Tokenable
  class TokensController < ::ActionController::API
    include Authable

    rescue_from 'Tokenable::Unauthorized' do
      render json: { error: 'Login failed, please try again.' }
    end

    def create
      user = Tokenable::Config.user_class.from_tokenable_params(params)
      raise Tokenable::Unauthorized, 'No user returned by strategy' unless user

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
