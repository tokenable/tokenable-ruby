# frozen_string_literal: true

require_relative 'controllers/tokens_controller'
require_relative 'strategies/devise'
require_relative 'strategies/sorcery'
require_relative 'strategies/secure_password'

module Tokenable
  class Engine < ::Rails::Engine
    isolate_namespace Tokenable
  end
end
