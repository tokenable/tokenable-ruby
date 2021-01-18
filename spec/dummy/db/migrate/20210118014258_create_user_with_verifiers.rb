class CreateUserWithVerifiers < ActiveRecord::Migration[6.1]
  def change
    create_table :user_with_verifiers do |t|
      t.string :email
      t.string :password_digest
      t.string :tokenable_verifier

      t.timestamps
    end
  end
end
