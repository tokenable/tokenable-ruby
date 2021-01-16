# frozen_string_literal: true

# The main controller concern that will be injected to the application
module Tokenable
  module Authable
    extend ActiveSupport::Concern

    included do
    end

    def user_signed_in?
      true
    end

    def current_user
      User.first
    end
  end
end
