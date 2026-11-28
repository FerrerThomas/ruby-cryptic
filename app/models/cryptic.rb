# Un críptico del catálogo. Se crean y actualizan desde la API de la cátedra
# (ver CrypticSynchronizer); el juego siempre los lee de la base.
#
#   cryptic = Cryptic.active.find_by!(source_id: "cr-013")
#   cryptic.statement             # => "Mi metido en el hogar da una prenda"
#   cryptic.enumeration           # => "(6)"
#   cryptic.material              # => ["Mi", "el hogar"]
#   cryptic.cryptic_type.key      # => "contenedor"
#   cryptic.correct_answer?("camisa") # => true
class Cryptic < ApplicationRecord
  # "(6)", o "(3,4)" si la respuesta tuviera varias palabras.
  ENUMERATION_FORMAT = /\A\((\d+(?:,\d+)*)\)\z/
  LIST_ATTRIBUTES = %i[definitions indicators material].freeze

  belongs_to :cryptic_type
  belongs_to :difficulty

  # El id de la fuente identifica al críptico al sincronizar: nunca cambia.
  attr_readonly :source_id

  normalizes :source_id, :statement, :enumeration, :answer, with: ->(value) { value.strip }

  validates :source_id, presence: true, uniqueness: true
  validates :statement, :answer, :origin, presence: true
  validates :enumeration, presence: true,
                          format: { with: ENUMERATION_FORMAT, message: "tiene que ser la cantidad de letras entre paréntesis, por ejemplo (6)" }
  validates :active, inclusion: { in: [ true, false ] }
  validate :lists_are_lists_of_text
  validate :at_least_one_definition
  validate :enumeration_matches_answer
  validate :fragments_appear_in_statement
  validates_with WordplayValidator

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  # Compara normalizado: «jamon», «Jamón» y « JAMÓN » son correctas.
  def correct_answer?(guess)
    TextNormalizer.letters(guess) == TextNormalizer.letters(answer)
  end

  # Cantidad de letras que indica la enumeración: "(6)" → 6, "(3,4)" → 7.
  def enumeration_letters
    match = ENUMERATION_FORMAT.match(enumeration.to_s)
    match && match[1].split(",").sum(&:to_i)
  end

  def to_s = "#{statement} #{enumeration}"

  private
    def lists_are_lists_of_text
      LIST_ATTRIBUTES.each do |attribute|
        value = public_send(attribute)
        next if value.is_a?(Array) && value.all? { |item| item.is_a?(String) && item.present? }

        errors.add(attribute, "tiene que ser una lista de textos")
      end
    end

    def at_least_one_definition
      errors.add(:definitions, "tienen que ser al menos una") if Array(definitions).empty?
    end

    # La enumeración cuenta letras: sin tildes ni espacios.
    def enumeration_matches_answer
      return if answer.blank? || enumeration_letters.nil?

      letters = TextNormalizer.letters(answer).length
      return if enumeration_letters == letters

      errors.add(:enumeration, "dice #{enumeration_letters} letras pero la respuesta tiene #{letters}")
    end

    # Cada definición, indicador y material es un fragmento del enunciado.
    def fragments_appear_in_statement
      return if statement.blank?

      LIST_ATTRIBUTES.each do |attribute|
        next unless public_send(attribute).is_a?(Array)

        public_send(attribute).each do |fragment|
          next if !fragment.is_a?(String) || statement.include?(fragment)

          errors.add(attribute, "«#{fragment}» no aparece en el enunciado")
        end
      end
    end
end
