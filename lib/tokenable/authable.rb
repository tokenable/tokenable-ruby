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
    rescue Tokenable::Unauthorized
      nil
    end

    def require_tokenable_user!
      raise Tokenable::Unauthorized.new('User is not signed in') unless user_signed_in?
      raise Tokenable::Unauthorized.new('Token verifier is invalid') if current_user.respond_to?(:valid_verifier?) && !current_user.valid_verifier?(jwt_verifier)
    end

    private

    def user_class
      User
    end

    def token_from_header
      request.authorization.to_s.split(' ').last
    end

    def token_from_user(user)
      jwt_data = {
        user_id: user.id,
      }

      if user.respond_to?(:issue_verifier!)
        jwt_data[:verifier] = user.current_verifier
      end

      JWT.encode(jwt_data, jwt_secret, 'HS256')
    end

    def jwt_user_id
      jwt['user_id']
    end

    def jwt_verifier
      jwt['verifier']
    end

    def jwt
      raise Tokenable::Unauthorized.new('Bearer token not provided') unless token_from_header.present?

      @jwt ||= JWT.decode(token_from_header, jwt_secret, true, { algorithm: 'HS256' }).first
    rescue JWT::ExpiredSignature, JWT::DecodeError
      raise Tokenable::Unauthorized.new('JWT exception thrown')
    end

    def jwt_secret
      Rails.application.secret_key_base
    end
  end
end
