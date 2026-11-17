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
