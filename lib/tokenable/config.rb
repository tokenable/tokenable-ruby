module Tokenable
  class Config
    # How long should the token last before it expires?
    # E.G: Tokenable::Config.lifespan = 7.days
    mattr_accessor :lifespan, default: nil

    # The secret used by JWT to encode the Token.
    # We default to Rails secret_key_base
    # This can be any 256 bit string.
    mattr_writer :secret, default: -> { Rails.application.secret_key_base }

    # The user model that we will perform actions on
    mattr_writer :user_class, default: -> { User }

    # We do this, as some of our defaults need to live in a Proc (as this library is loaded before Rails)
    # This means we can return the value when the method is called, instead of the Proc.
    def self.method_missing(method_name, *args, &block)
      self.class_variable_defined?("@@#{method_name}") ? self.proc_reader(method_name) : super
    end

    private

    def self.proc_reader(key)
      value = self.class_variable_get("@@#{key}")
      value.is_a?(Proc) ? value.call : value
    end
  end
end
