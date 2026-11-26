require "test_helper"

class TextNormalizerTest < ActiveSupport::TestCase
  test "saca tildes, mayúsculas, espacios y signos" do
    assert_equal "jamon", TextNormalizer.letters("jamon")
    assert_equal "jamon", TextNormalizer.letters("Jamón")
    assert_equal "jamon", TextNormalizer.letters(" JAMÓN ")
    assert_equal "pinguino", TextNormalizer.letters("¡Pingüino!")
  end

  test "la ñ se distingue de la n" do
    assert_equal "año", TextNormalizer.letters("AÑO")
    assert_not_equal TextNormalizer.letters("año"), TextNormalizer.letters("ano")
  end

  test "nil da texto vacío" do
    assert_equal "", TextNormalizer.letters(nil)
  end

  test "words separa en palabras normalizadas y descarta los signos sueltos" do
    assert_equal %w[album casa y amor], TextNormalizer.words("álbum, casa y amor")
    assert_equal %w[hola], TextNormalizer.words("  hola  — ")
  end
end
