# frozen_string_literal: true

module Tokenable
  class Config
    # How long should the token last before it expires?
    # E.G: Tokenable::Config.lifespan = 14.days
    # You could set this to nil to disable expiring keys
    mattr_writer :lifespan, default: -> { 7.days }

    # The secret used by JWT to encode the Token.
    # We default to Rails secret_key_base
    # This can be any 256 bit string.
    mattr_writer :secret, default: -> { Rails.application.secret_key_base }

    # The user model that we will perform actions on
    mattr_writer :user_class, default: -> { 'User' }

    def self.user_class
      class_name = proc_reader(:user_class)
      class_name.is_a?(String) ? class_name.constantize : class_name
    end

    # We do this, as some of our defaults need to live in a Proc (as this library is loaded before Rails)
    # This means we can return the value when the method is called, instead of the Proc.
    def self.method_missing(method_name, *args, &block)
      class_variable_defined?("@@#{method_name}") ? proc_reader(method_name) : super
    end

    def self.respond_to_missing?(method_name, include_private = false)
      class_variable_defined?("@@#{method_name}") || super
    end

    def self.proc_reader(key)
      value = class_variable_get("@@#{key}")
      value.is_a?(Proc) ? value.call : value
    end
  end
end
