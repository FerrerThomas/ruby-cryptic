class AddRoleAndActiveToUsers < ActiveRecord::Migration[8.1]
  def change
    # Por defecto el rol con menos permisos: un admin se crea a propósito.
    add_column :users, :role, :string, null: false, default: "score_editor"
    add_column :users, :active, :boolean, null: false, default: true

    add_check_constraint :users, "role IN ('admin', 'score_editor')", name: "users_role_check"
  end
end
