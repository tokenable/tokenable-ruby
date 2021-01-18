# frozen_string_literal: true

# The main controller concern that will be injected to the application

require 'jwt'
require 'active_support/concern'

module Tokenable
  module Authable
    extend ActiveSupport::Concern

    def user_signed_in?
      current_user.present?
    end

    def current_user
      @current_user ||= user_class.find_by(id: jwt_user_id)
    rescue Tokenable::Unauthorized
      nil
    end

    def require_tokenable_user!
      raise Tokenable::Unauthorized, 'User not found in JWT token' unless jwt_user_id
      raise Tokenable::Unauthorized, 'User is not signed in' unless user_signed_in?
      raise Tokenable::Unauthorized, 'Token verifier is invalid' unless valid_token?
    end

    private

    def verifier_enabled?
      user_class.included_modules.include?(Tokenable::Verifier)
    end

    def valid_token?
      return true unless verifier_enabled?

      current_user.valid_verifier?(jwt_verifier)
    end

    def user_class
      Tokenable::Config.user_class
    end

    def token_from_header
      request.authorization.to_s.split.last
    end

    def token_from_user(user)
      jwt_data = {
        data: {
          user_id: user.id,
        },
      }

      jwt_data[:exp] = jwt_expiry_time if jwt_expiry_time

      jwt_data[:data][:verifier] = user.current_verifier if verifier_enabled?

      JWT.encode(jwt_data, jwt_secret, 'HS256')
    end

    def jwt_user_id
      jwt.dig('data', 'user_id')
    end

    def jwt_verifier
      jwt.dig('data', 'verifier')
    end

    def jwt
      raise Tokenable::Unauthorized, 'Bearer token not provided' unless token_from_header.present?

      @jwt ||= JWT.decode(token_from_header, jwt_secret, true, { algorithm: 'HS256' }).first.to_h
    rescue JWT::ExpiredSignature
      raise Tokenable::Unauthorized, 'Token has expired'
    rescue JWT::VerificationError
      raise Tokenable::Unauthorized, 'The tokenable secret used in this token does not match the one supplied in Tokenable::Config.secret'
    rescue JWT::DecodeError
      raise Tokenable::Unauthorized, 'JWT exception thrown'
    end

    def jwt_expiry_time
      Tokenable::Config.lifespan ? Tokenable::Config.lifespan.from_now.to_i : nil
    end

    def jwt_secret
      Tokenable::Config.secret
    end
  end
end
