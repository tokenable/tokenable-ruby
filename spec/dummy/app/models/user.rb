class User < ApplicationRecord
  include Tokenable::Verifier
  include Tokenable::Strategies::SecurePassword
end
