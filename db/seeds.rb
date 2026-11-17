# Datos de prueba para evaluar el sistema. Se cargan con `bin/rails db:seed`
# (o junto con la base con `bin/rails db:setup`).
#
# Tiene que ser idempotente: se puede correr varias veces sin duplicar datos.
# Cada tarea agrega su sección (crípticos, jugadores, partidas, etc.).

# --- Usuarios del backend (#2) ---
# Las credenciales están en el README. Si el usuario ya existe no se toca,
# así no se pisa una contraseña que alguien haya cambiado.
puts "Creando usuarios del backend..."

[
  { email_address: "admin@rubipticos.test", password: "admin1234", role: "admin" },
  { email_address: "editor@rubipticos.test", password: "editor1234", role: "score_editor" }
].each do |attrs|
  User.find_or_create_by!(email_address: attrs[:email_address]) do |user|
    user.password = attrs[:password]
    user.role = attrs[:role]
  end
end

# --- Configuración del juego (#5) ---
# Tipos y dificultades que reconoce el sistema (las claves son las de la API).
# Valores iniciales del enunciado: 100 puntos por tipo, multiplicadores 1, 2 y 3.
# Si la fila ya existe no se toca, así no se pisan valores editados desde el backend.
# Tiene que ir ANTES de cargar los crípticos, que referencian tipos y dificultades.
puts "Creando tipos de críptico y dificultades..."

{
  "anagrama" => "Anagrama",
  "oculta" => "Oculta",
  "charada" => "Charada",
  "contenedor" => "Contenedor",
  "inversion" => "Inversión",
  "supresion" => "Supresión",
  "homofono" => "Homófono",
  "doble_definicion" => "Doble definición",
  "iniciales" => "Iniciales",
  "finales" => "Finales",
  "sustitucion" => "Sustitución",
  "simbolos" => "Símbolos",
  "combinada" => "Combinada"
}.each do |key, name|
  CrypticType.find_or_create_by!(key: key) do |type|
    type.name = name
    type.points = 100
  end
end

[
  { key: "facil", name: "Fácil", multiplier: 1, reference_seconds: 60 },
  { key: "medio", name: "Medio", multiplier: 2, reference_seconds: 180 },
  { key: "avanzado", name: "Avanzado", multiplier: 3, reference_seconds: 300 }
].each.with_index(1) do |attrs, position|
  Difficulty.find_or_create_by!(key: attrs[:key]) do |difficulty|
    difficulty.assign_attributes(attrs.except(:key).merge(position: position))
  end
end

# URL de la fuente de crípticos y texto de bienvenida (valores por defecto en Setting).
Setting.current
