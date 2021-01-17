# frozen_string_literal: true

require_relative 'tokenable/version'
require_relative 'tokenable/authable'
require_relative 'tokenable/verifier'
require_relative 'tokenable/railtie' if defined?(Rails)

module Tokenable
  class Error < StandardError; end

  class Unauthorized < Error; end

  # How long should the token last before it expires?
  # E.G: Tokenable.lifespan = 7.days
  mattr_accessor :lifespan
  self.lifespan = nil

  # The secret used by JWT to encode the Token.
  # We default to Rails secret_key_base
  # This can be any 256 bit string.
  mattr_accessor :secret
  self.secret = -> do
    Rails.application.secret_key_base
  end
end
