# frozen_string_literal: true

module Tokenable
  module Verifier
    extend ActiveSupport::Concern

    def valid_verifier?(verifier)
      raise Tokenable::Unauthorized, "#{verifier_key} field is missing" unless respond_to?(verifier_key)

      current_verifier == verifier
    end

    def current_verifier
      send(verifier_key) || issue_verifier!
    end

    def invalidate_tokens!
      issue_verifier!
    end

    def issue_verifier!
      update!(verifier_key => SecureRandom.uuid)
      send(verifier_key)
    end

    private

    def verifier_key
      :tokenable_verifier
    end
  end
end
