module Tokenable
  module Revokable
    extend ActiveSupport::Concern

    def token_revoked?(revoke_token)
      !revoke_token.in?(revoke_tokens_hash.keys)
    end

    def issue_revoke_token
      issued_token = SecureRandom.hex
      self.update(
        revoke_tokens_key => revoke_tokens_hash.merge(
          issued_token => Time.current
        )
      )

      issued_token
    end

    private

    def revoke_tokens_hash
      raise Tokenable::Unauthorized.new("#{revoke_tokens_key} field is missing") unless self.has_attribute?(revoke_tokens_key)

      read_attribute(revoke_tokens_key).to_h
    end

    # TODO: make a config option
    def revoke_tokens_key
      :revoke_tokens
    end
  end
end
