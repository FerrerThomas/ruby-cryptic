# Normaliza texto para comparar palabras como pide el enunciado:
# sin tildes, sin mayúsculas y sin espacios ni signos. La Ñ se distingue de la N.
#
#   TextNormalizer.letters(" JAMÓN ")          # => "jamon"
#   TextNormalizer.letters("Año")              # => "año"
#   TextNormalizer.words("álbum, casa y amor") # => ["album", "casa", "y", "amor"]
#
# Lo usan las validaciones de Cryptic y sirve para comparar la respuesta del jugador.
module TextNormalizer
  ACCENTED = "áàäâéèëêíìïîóòöôúùüû".freeze
  PLAIN    = "aaaaeeeeiiiioooouuuu".freeze

  module_function

  # Solo las letras, en minúscula y sin tildes (la ñ queda como ñ).
  def letters(text)
    text.to_s.downcase.tr(ACCENTED, PLAIN).gsub(/[^a-zñ]/, "")
  end

  # Las palabras del texto, cada una normalizada. Descarta lo que no tiene letras.
  def words(text)
    text.to_s.split(/\s+/).map { |word| letters(word) }.reject(&:empty?)
  end
end
