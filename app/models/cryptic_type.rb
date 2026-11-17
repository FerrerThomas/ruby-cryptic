# Tipo de juego de palabras (anagrama, oculta, charada, ...).
# Las filas las crea db/seeds.rb; desde el backend solo se editan los puntos.
#
#   CrypticType.find_by!(key: "anagrama").points  # => 100
class CrypticType < ApplicationRecord
  KEY_FORMAT = /\A[a-z_]+\z/

  # La clave es la que trae la API: no se cambia una vez creada.
  attr_readonly :key

  validates :key, presence: true, uniqueness: true, format: { with: KEY_FORMAT }
  validates :name, presence: true
  validates :points, numericality: { only_integer: true, greater_than_or_equal_to: 10, less_than_or_equal_to: 1000 }

  scope :ordered, -> { order(:name) }

  def to_s = name
end
