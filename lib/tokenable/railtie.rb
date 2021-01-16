# frozen_string_literal: true

require_relative 'authable'
require_relative 'engine'

module Tokebale
  class Railtie < ::Rails::Railtie
    railtie_name :tokenable
  end
end
