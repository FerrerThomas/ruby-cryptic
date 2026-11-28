# Verifica que el juego de palabras de un críptico tenga sentido según su tipo.
# Es la parte en la que "el sistema verifica crípticos por sí mismo".
#
#   oculta            la respuesta está escrita de corrido dentro del material
#   anagrama          el material tiene exactamente las mismas letras que la respuesta
#   iniciales         las primeras letras de las palabras del material forman la respuesta
#   finales           las últimas letras de las palabras del material forman la respuesta
#   doble_definicion  lleva exactamente 2 definiciones
#
# Los demás tipos (charada, contenedor, homófono, ...) necesitan sinónimos que el
# sistema no conoce (el hogar = CASA), así que no se pueden verificar automáticamente.
class WordplayValidator < ActiveModel::Validator
  # Palabras de unión que se ignoran en iniciales/finales:
  # en «Colas de álbum, casa y amor» la "y" no aporta su letra (MAR, no MAYR).
  CONNECTORS = %w[y e o u ni].freeze

  def validate(cryptic)
    return if cryptic.answer.blank? || cryptic.cryptic_type.nil?

    case cryptic.cryptic_type.key
    when "doble_definicion" then validate_double_definition(cryptic)
    when "oculta"           then validate_hidden(cryptic)
    when "anagrama"         then validate_anagram(cryptic)
    when "iniciales"        then validate_letters_of_each_word(cryptic, :first)
    when "finales"          then validate_letters_of_each_word(cryptic, :last)
    end
  end

  private
    def validate_double_definition(cryptic)
      return if Array(cryptic.definitions).size == 2

      cryptic.errors.add(:definitions, "tienen que ser exactamente 2 en una doble definición")
    end

    # «cama tejida» → "camatejida", que contiene "mate".
    def validate_hidden(cryptic)
      return if material_letters(cryptic).include?(answer_letters(cryptic))

      cryptic.errors.add(:material, "no esconde la respuesta de corrido")
    end

    # «Monja» y «JAMÓN» tienen las mismas letras: a, j, m, n, o.
    def validate_anagram(cryptic)
      return if material_letters(cryptic).chars.sort == answer_letters(cryptic).chars.sort

      cryptic.errors.add(:material, "no tiene exactamente las mismas letras que la respuesta")
    end

    # «ocho sapos observan» → O + S + O = OSO.
    # Se prueba con todas las palabras y también sin las palabras de unión.
    def validate_letters_of_each_word(cryptic, position)
      words = TextNormalizer.words(Array(cryptic.material).join(" "))
      candidates = [ words, words - CONNECTORS ]

      formed = candidates.map { |list| list.map { |word| word.public_send(position) }.join }
      return if formed.include?(answer_letters(cryptic))

      which = position == :first ? "primeras" : "últimas"
      cryptic.errors.add(:material, "no forma la respuesta con las #{which} letras de sus palabras")
    end

    def material_letters(cryptic)
      TextNormalizer.letters(Array(cryptic.material).join)
    end

    def answer_letters(cryptic)
      TextNormalizer.letters(cryptic.answer)
    end
end
