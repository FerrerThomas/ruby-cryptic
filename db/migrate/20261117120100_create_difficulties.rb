class CreateDifficulties < ActiveRecord::Migration[8.1]
  def change
    # Fácil, medio y avanzado: su multiplicador (configurable) y su tiempo de referencia (fijo).
    create_table :difficulties do |t|
      t.string :key, null: false                                  # clave de la API: "medio"
      t.string :name, null: false                                 # para mostrar: "Medio"
      t.decimal :multiplier, precision: 3, scale: 2, null: false  # 0.01 a 5.00
      t.integer :reference_seconds, null: false                   # 60 / 180 / 300
      t.integer :position, null: false                            # orden en pantalla

      t.timestamps
    end

    add_index :difficulties, :key, unique: true
    add_index :difficulties, :position, unique: true
    add_check_constraint :difficulties, "multiplier > 0 AND multiplier <= 5", name: "difficulties_multiplier_range"
    add_check_constraint :difficulties, "reference_seconds > 0", name: "difficulties_reference_seconds_positive"
  end
end
