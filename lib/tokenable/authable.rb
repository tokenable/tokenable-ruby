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
    rescue Tokenable::Unauthorized
      false
    end

    def current_user
      @current_user ||= user_class.find(jwt_user_id)
    end

    def require_tokenable_user!
      raise Tokenable::Unauthorized unless user_signed_in?
    end

    private

    def user_class
      User
    end

    def token_from_header
      headers['Authorization'].to_s.split(' ').last
    end

    def jwt_user_id
      jwt['data']['user_id']
    rescue Tokenable::Unauthorized
      nil
    end

    def jwt
      raise Tokenable::Unauthorized unless token_from_header.present?

      @jwt ||= JWT.decode(token_from_header, jwt_secret, true, { algorithm: 'HS256' }).first
    rescue JWT::ExpiredSignature, JWT::DecodeError
      raise Tokenable::Unauthorized
    end

    def jwt_secret
      Rails.application.secret_key_base
    end
  end
end
