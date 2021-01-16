module Tokenable
  module Revocable
    extend ActiveSupport::Concern

    def valid_verifier?(verifier)
      raise Tokenable::Unauthorized.new("#{verifier_key} field is missing") unless self.has_attribute?(verifier_key)

      current_verifier == verifier
    end

    def current_verifier
      read_attribute(verifier_key) || issue_verifier!
    end

    def invalidate_tokens!
      issue_verifier!
    end

    def issue_verifier!
      self.update!(verifier_key => SecureRandom.uuid)
      read_attribute(verifier_key)
    end

    private

    def verifier_key
      :tokenable_verifier
    end
  end
end
