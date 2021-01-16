# frozen_string_literal: true

require_relative 'authable'

module Tokebale
  class Railtie < ::Rails::Railtie
    railtie_name :tokenable
  end
end
