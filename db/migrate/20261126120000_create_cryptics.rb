class CreateCryptics < ActiveRecord::Migration[8.1]
  def change
    create_table :cryptics do |t|
      t.string :source_id, null: false           # id en la API: "cr-013"
      t.text :statement, null: false             # enunciado, sin la enumeración
      t.string :enumeration, null: false         # "(6)"
      t.string :answer, null: false              # "CAMISA" (mayúsculas, con tildes)
      t.json :definitions, null: false, default: []
      t.json :indicators, null: false, default: []
      t.json :material, null: false, default: []
      t.references :cryptic_type, null: false, foreign_key: true
      t.references :difficulty, null: false, foreign_key: true
      t.text :help_text                          # "ayuda": la cuarta pista
      t.text :explanation                        # se muestra al resolver o rendirse
      t.string :author
      t.string :origin, null: false              # de qué fuente vino ("fuente" del catálogo)
      t.boolean :active, null: false, default: true
      t.timestamps
    end

    add_index :cryptics, :source_id, unique: true
    add_index :cryptics, :active

    # Las tres listas tienen que ser listas JSON, aunque estén vacías.
    %i[definitions indicators material].each do |column|
      add_check_constraint :cryptics, "json_type(#{column}) = 'array'", name: "cryptics_#{column}_is_array"
    end
    add_check_constraint :cryptics, "length(trim(statement)) > 0 AND length(trim(answer)) > 0",
                         name: "cryptics_statement_and_answer_not_blank"
  end
end
