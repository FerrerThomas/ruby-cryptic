# Configuración general del juego: una sola fila, siempre con id 1.
# Se edita desde el backend (solo admins).
#
#   Setting.current.cryptics_source_url  # URL de la API de crípticos
#   Setting.current.welcome_text         # texto de la pantalla de bienvenida
class Setting < ApplicationRecord
  SINGLETON_ID = 1

  DEFAULT_CRYPTICS_SOURCE_URL = "https://ecorrons.github.io/cryptics-api/v1/cryptics.json".freeze
  DEFAULT_WELCOME_TEXT = "Cada críptico esconde una palabra dos veces: una en su definición " \
                         "y otra en un juego de palabras. Elegí una dificultad, descifrala y sumá puntos.".freeze

  WELCOME_TEXT_MAX_LENGTH = 1000

  validates :cryptics_source_url, presence: true,
                                  format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]),
                                            message: "tiene que ser una URL que empiece con http:// o https://" }
  validates :welcome_text, presence: true, length: { maximum: WELCOME_TEXT_MAX_LENGTH }

  # Devuelve la configuración; si todavía no existe, la crea con los valores por defecto.
  def self.current
    find_or_create_by!(id: SINGLETON_ID) do |setting|
      setting.cryptics_source_url = DEFAULT_CRYPTICS_SOURCE_URL
      setting.welcome_text = DEFAULT_WELCOME_TEXT
    end
  end
end
