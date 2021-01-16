# frozen_string_literal: true

# The main controller concern that will be injected to the application

require 'jwt'
require 'active_support/concern'

module Tokenable
  module Authable
    extend ActiveSupport::Concern

    included do
    end

    def user_signed_in?
      current_user.present?
    end

    def current_user
      @user ||= user_class.find(jwt_user_id)
    end

    private

    def user_class
      User
    end

    def token_from_header
      headers['Authorization'].split(' ').last
    end

    def jwt_user_id
      jwt['data']['user_id']
    end

    def jwt
      @jwt ||= JWT.decode(token_from_header, jwt_secret, true, { algorithm: 'HS256' }).first
    end

    def jwt_secret
      Rails.application.secret_key_base
    end
  end
end
