# frozen_string_literal: true

require_relative 'tokenable/version'
require_relative 'tokenable/railtie' if defined?(Rails)

module Tokenable
  class Error < StandardError; end
  # Your code goes here...
end
