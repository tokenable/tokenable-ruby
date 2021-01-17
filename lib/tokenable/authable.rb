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
      @current_user ||= user_class.find(jwt_user_id)
    rescue Tokenable::Unauthorized
      nil
    end

    def require_tokenable_user!
      raise Tokenable::Unauthorized.new('User not found in JWT token') unless jwt_user_id
      raise Tokenable::Unauthorized.new('User is not signed in') unless user_signed_in?
      raise Tokenable::Unauthorized.new('Token verifier is invalid') if user_class.included_modules.include?(Tokenable::Verifier) && !current_user.valid_verifier?(jwt_verifier)
    end

    private

    def user_class
      Tokenable::Config.user_class
    end

    def token_from_header
      request.authorization.to_s.split(' ').last
    end

    def token_from_user(user)
      jwt_data = {
        data: {
          user_id: user.id,
        }
      }

      if jwt_expiry_time
        jwt_data[:exp] = jwt_expiry_time
      end

      if user_class.included_modules.include?(Tokenable::Verifier)
        jwt_data[:data][:verifier] = user.current_verifier
      end

      JWT.encode(jwt_data, jwt_secret, 'HS256')
    end

    def jwt_user_id
      jwt.dig('data', 'user_id')
    end

    def jwt_verifier
      jwt.dig('data', 'verifier')
    end

    def jwt
      raise Tokenable::Unauthorized.new('Bearer token not provided') unless token_from_header.present?

      @jwt ||= JWT.decode(token_from_header, jwt_secret, true, { algorithm: 'HS256' }).first.to_h
    rescue JWT::ExpiredSignature
      raise Tokenable::Unauthorized.new('Token has expired')
    rescue JWT::VerificationError
      raise Tokenable::Unauthorized.new('The tokenable secret used in this token does not match the one supplied in Tokenable.secret')
    rescue JWT::DecodeError
      raise Tokenable::Unauthorized.new('JWT exception thrown')
    end

    def jwt_expiry_time
      Tokenable::Config.lifespan
    end

    def jwt_secret
      Tokenable::Config.secret
    end
  end
end
