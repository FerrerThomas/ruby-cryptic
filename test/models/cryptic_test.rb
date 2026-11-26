require "test_helper"

class CrypticTest < ActiveSupport::TestCase
  # Un críptico válido de tipo oculta; cada test cambia solo lo que quiere probar.
  def build_cryptic(**attrs)
    Cryptic.new({
      source_id: "cr-900",
      statement: "Pato rosado esconde un animal de las corridas",
      enumeration: "(4)",
      answer: "TORO",
      definitions: [ "un animal de las corridas" ],
      indicators: [ "esconde" ],
      material: [ "Pato rosado" ],
      cryptic_type: cryptic_types(:oculta),
      difficulty: difficulties(:facil),
      origin: "Cátedra de Ruby on Rails"
    }.merge(attrs))
  end

  test "un críptico completo es válido" do
    assert build_cryptic.valid?
  end

  # --- Obligatorios, tipo y dificultad ---

  test "enunciado, respuesta, tipo y dificultad son obligatorios" do
    cryptic = build_cryptic(statement: "", answer: "", cryptic_type: nil, difficulty: nil)

    assert_not cryptic.valid?
    assert cryptic.errors.of_kind?(:statement, :blank)
    assert cryptic.errors.of_kind?(:answer, :blank)
    assert cryptic.errors.of_kind?(:cryptic_type, :blank)
    assert cryptic.errors.of_kind?(:difficulty, :blank)
  end

  test "el id de la fuente es obligatorio y único" do
    assert_not build_cryptic(source_id: "").valid?
    assert_not build_cryptic(source_id: cryptics(:mate).source_id).valid?
  end

  test "la base rechaza un tipo que no existe" do
    cryptic = build_cryptic
    cryptic.save!

    assert_raises(ActiveRecord::InvalidForeignKey) do
      cryptic.update_column(:cryptic_type_id, CrypticType.maximum(:id) + 1)
    end
  end

  test "no se puede borrar un tipo que tiene crípticos" do
    type = cryptics(:mate).cryptic_type

    assert_not type.destroy
    assert CrypticType.exists?(type.id)
  end

  # --- Enumeración ---

  test "la enumeración coincide con el largo de la respuesta sin contar tildes" do
    assert build_cryptic(statement: "Monja alborotada da un fiambre", answer: "JAMÓN", enumeration: "(5)",
                         definitions: [ "un fiambre" ], indicators: [ "alborotada" ], material: [ "Monja" ],
                         cryptic_type: cryptic_types(:anagrama)).valid?
  end

  test "la enumeración que no coincide con la respuesta es inválida" do
    cryptic = build_cryptic(enumeration: "(5)")

    assert_not cryptic.valid?
    assert_includes cryptic.errors[:enumeration].join, "dice 5 letras pero la respuesta tiene 4"
  end

  test "la enumeración tiene que tener el formato (n)" do
    assert_not build_cryptic(enumeration: "4").valid?
    assert_not build_cryptic(enumeration: "(cuatro)").valid?
  end

  # --- Fragmentos en el enunciado ---

  test "cada definición, indicador y material aparece en el enunciado" do
    cryptic = build_cryptic(definitions: [ "una planta" ], indicators: [ "oculta" ], material: [ "Gato rosado" ])

    assert_not cryptic.valid?
    assert_includes cryptic.errors[:definitions].join, "«una planta» no aparece en el enunciado"
    assert_includes cryptic.errors[:indicators].join, "«oculta» no aparece en el enunciado"
    assert_includes cryptic.errors[:material].join, "«Gato rosado» no aparece en el enunciado"
  end

  test "las listas tienen que ser listas de textos" do
    assert_not build_cryptic(material: "Pato rosado").valid?
    assert_not build_cryptic(indicators: [ 1 ]).valid?
  end

  test "tiene que haber al menos una definición" do
    assert_not build_cryptic(definitions: []).valid?
  end

  # --- Validaciones por tipo ---

  test "doble definición lleva exactamente 2 definiciones" do
    attrs = { statement: "Felino o herramienta para cambiar la rueda", answer: "GATO", indicators: [], material: [],
              cryptic_type: cryptic_types(:doble_definicion) }

    assert build_cryptic(**attrs, definitions: [ "Felino", "herramienta para cambiar la rueda" ]).valid?
    assert_not build_cryptic(**attrs, definitions: [ "Felino" ]).valid?
  end

  test "oculta: la respuesta está de corrido dentro del material" do
    assert build_cryptic.valid? # paTO ROsado

    cryptic = build_cryptic(statement: "Pato blanco esconde un animal de las corridas", material: [ "Pato blanco" ])
    assert_not cryptic.valid?
    assert_includes cryptic.errors[:material].join, "no esconde la respuesta"
  end

  test "anagrama: el material tiene las mismas letras que la respuesta" do
    attrs = { statement: "Monja alborotada da un fiambre", definitions: [ "un fiambre" ], indicators: [ "alborotada" ],
              material: [ "Monja" ], enumeration: "(5)", cryptic_type: cryptic_types(:anagrama) }

    assert build_cryptic(**attrs, answer: "JAMÓN").valid?
    assert_not build_cryptic(**attrs, answer: "JAMÁS").valid? # el caso cr-103 del catálogo con errores
  end

  test "iniciales: las primeras letras del material forman la respuesta" do
    attrs = { statement: "Al principio, ocho sapos observan un animal peludo", definitions: [ "un animal peludo" ],
              indicators: [ "Al principio" ], material: [ "ocho sapos observan" ], enumeration: "(3)",
              cryptic_type: cryptic_types(:iniciales) }

    assert build_cryptic(**attrs, answer: "OSO").valid?
    assert_not build_cryptic(**attrs, answer: "OJO").valid?
  end

  test "finales: las últimas letras forman la respuesta, ignorando palabras de unión" do
    attrs = { statement: "Colas de álbum, casa y amor dan agua salada", definitions: [ "agua salada" ],
              indicators: [ "Colas de" ], material: [ "álbum, casa y amor" ], enumeration: "(3)",
              cryptic_type: cryptic_types(:finales) }

    assert build_cryptic(**attrs, answer: "MAR").valid? # álbuM casA (y) amoR
    assert_not build_cryptic(**attrs, answer: "SOL").valid?
  end

  test "los tipos que necesitan sinónimos no se verifican automáticamente" do
    camisa = cryptics(:camisa)

    assert camisa.valid?
  end

  # --- Restricciones en la base ---

  test "la base exige los campos obligatorios aunque se saltee la validación" do
    assert_raises(ActiveRecord::NotNullViolation) do
      cryptics(:mate).update_column(:answer, nil)
    end
  end

  test "la base rechaza un id de la fuente repetido" do
    cryptic = build_cryptic(source_id: cryptics(:mate).source_id)

    assert_raises(ActiveRecord::RecordNotUnique) { cryptic.save!(validate: false) }
  end

  test "la base rechaza listas que no son listas" do
    assert_raises(ActiveRecord::StatementInvalid) do
      cryptics(:mate).update_column(:material, "cama tejida")
    end
  end

  # --- Otros ---

  test "correct_answer? compara normalizado" do
    cryptic = build_cryptic(answer: "TORO")

    assert cryptic.correct_answer?("toro")
    assert cryptic.correct_answer?(" Toro! ")
    assert_not cryptic.correct_answer?("toros")
  end

  test "scopes active e inactive" do
    assert_includes Cryptic.active, cryptics(:mate)
    assert_includes Cryptic.inactive, cryptics(:camisa)
    assert_not_includes Cryptic.active, cryptics(:camisa)
  end

  test "normaliza espacios de más en la respuesta y el enunciado" do
    cryptic = build_cryptic(answer: "  TORO ", statement: " Pato rosado esconde un animal de las corridas ")

    assert_equal "TORO", cryptic.answer
    assert cryptic.valid?
  end

  # --- Contra los catálogos reales de la cátedra ---

  test "todos los crípticos del catálogo de la cátedra son válidos" do
    Cryptic.delete_all # los fixtures usan ids del catálogo (cr-001, cr-013)
    catalog = JSON.parse(file_fixture("cryptics.json").read)

    catalog["cripticos"].each do |data|
      cryptic = cryptic_from_api(data, catalog["fuente"])
      assert cryptic.valid?, "#{data["id"]} debería ser válido: #{cryptic.errors.full_messages.to_sentence}"
    end
  end

  test "el catálogo con errores tiene crípticos que se rechazan" do
    catalog = JSON.parse(file_fixture("cryptics_with_errors.json").read)
    invalid = catalog["cripticos"].reject { |data| cryptic_from_api(data, catalog["fuente"]).valid? }

    assert_equal %w[cr-102 cr-103 cr-104 cr-105 cr-107], invalid.map { |data| data["id"] }.sort
  end

  private
    # Arma un Cryptic a partir de un elemento del JSON de la API, creando los tipos
    # que no están en los fixtures. Un tipo o dificultad desconocidos quedan en nil.
    def cryptic_from_api(data, source)
      ensure_all_cryptic_types

      Cryptic.new(
        source_id: data["id"], statement: data["enunciado"], enumeration: data["enumeracion"],
        answer: data["respuesta"], definitions: data["definiciones"], indicators: data["indicadores"],
        material: data["material"], help_text: data["ayuda"], explanation: data["explicacion"],
        author: data["autor"], origin: source,
        cryptic_type: CrypticType.find_by(key: data["tipo"]),
        difficulty: Difficulty.find_by(key: data["dificultad"])
      )
    end

    def ensure_all_cryptic_types
      %w[anagrama oculta charada contenedor inversion supresion homofono doble_definicion
         iniciales finales sustitucion simbolos combinada].each do |key|
        CrypticType.find_or_create_by!(key: key) { |type| type.name = key.humanize }
      end
    end
end
