# Dificultad de un críptico (fácil, medio, avanzado).
# Las filas las crea db/seeds.rb; desde el backend solo se edita el multiplicador.
# El tiempo de referencia es fijo (lo define el enunciado).
#
#   medio = Difficulty.find_by!(key: "medio")
#   medio.multiplier         # => 2.0
#   medio.reference_seconds  # => 180
class Difficulty < ApplicationRecord
  KEY_FORMAT = /\A[a-z_]+\z/

  # La clave viene de la API y el tiempo de referencia es fijo: no se cambian una vez creados.
  attr_readonly :key, :reference_seconds

  validates :key, presence: true, uniqueness: true, format: { with: KEY_FORMAT }
  validates :name, presence: true
  validates :multiplier, numericality: { greater_than: 0, less_than_or_equal_to: 5 }
  validates :reference_seconds, numericality: { only_integer: true, greater_than: 0 }
  validates :position, numericality: { only_integer: true }, uniqueness: true

  scope :ordered, -> { order(:position) }

  def to_s = name
end
