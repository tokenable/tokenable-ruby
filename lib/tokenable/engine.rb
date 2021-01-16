require_relative 'tokens_controller'

module Tokenable
  class Engine < ::Rails::Engine
    isolate_namespace Tokenable
  end
end
