# frozen_string_literal: true

require_relative 'tokenable/version'
require_relative 'tokenable/authable'
require_relative 'tokenable/verifier'
require_relative 'tokenable/railtie' if defined?(Rails)

module Tokenable
  class Error < StandardError; end

  class Unauthorized < Error; end
end
