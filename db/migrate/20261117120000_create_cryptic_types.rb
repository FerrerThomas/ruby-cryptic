class CreateCrypticTypes < ActiveRecord::Migration[8.1]
  def change
    # Un tipo de juego de palabras (anagrama, oculta, ...) y cuántos puntos vale.
    create_table :cryptic_types do |t|
      t.string :key, null: false     # clave de la API: "doble_definicion"
      t.string :name, null: false    # para mostrar: "Doble definición"
      t.integer :points, null: false, default: 100

      t.timestamps
    end

    add_index :cryptic_types, :key, unique: true
    add_check_constraint :cryptic_types, "points BETWEEN 10 AND 1000", name: "cryptic_types_points_range"
  end
end
