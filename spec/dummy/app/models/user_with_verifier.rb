class UserWithVerifier < ApplicationRecord
  include Tokenable::Verifier
end
