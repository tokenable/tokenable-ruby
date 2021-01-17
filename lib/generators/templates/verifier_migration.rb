class AddTokenableVerifierTo<%= table_name.camelize %> < ActiveRecord::Migration<%= migration_version %>
  def change
    add_column :<%= table_name %>, :tokenable_verifier, :uuid
  end
end
