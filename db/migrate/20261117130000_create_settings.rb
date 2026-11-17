class CreateSettings < ActiveRecord::Migration[8.1]
  def change
    # Configuración general del juego. Es una tabla de UNA sola fila (id = 1).
    create_table :settings do |t|
      t.string :cryptics_source_url, null: false
      t.text :welcome_text, null: false

      t.timestamps
    end

    add_check_constraint :settings, "id = 1", name: "settings_single_row"
  end
end
