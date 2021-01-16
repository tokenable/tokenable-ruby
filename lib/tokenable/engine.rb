require_relative 'tokens_controller'
require_relative 'strategies/secure_password'

module Tokenable
  class Engine < ::Rails::Engine
    isolate_namespace Tokenable
  end
end
