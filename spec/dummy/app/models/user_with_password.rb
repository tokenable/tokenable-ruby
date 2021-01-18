class UserWithPassword < ApplicationRecord
  self.table_name = 'users'
  has_secure_password

  include Tokenable::Strategies::SecurePassword
end
