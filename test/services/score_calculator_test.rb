require "test_helper"

class ScoreCalculatorTest < ActiveSupport::TestCase
  # Fixtures: anagrama vale 100 puntos; medio es ×2 con referencia de 180 s.
  def calculate(**overrides)
    ScoreCalculator.call(**{
      cryptic_type: cryptic_types(:anagrama),
      difficulty: difficulties(:medio),
      elapsed_seconds: 120,
      hints_used: 0,
      streak_days: 0
    }.merge(overrides))
  end

  test "ejemplo del enunciado: medio, 240 s, 1 pista, 4 días de racha = 144" do
    assert_equal 144, calculate(elapsed_seconds: 240, hints_used: 1, streak_days: 4)
  end

  test "ejemplo del enunciado: en 2 minutos y sin pistas = 240" do
    assert_equal 240, calculate(elapsed_seconds: 120, streak_days: 4)
  end

  test "la base usa los puntos del tipo y el multiplicador configurados" do
    cryptic_types(:anagrama).update!(points: 150)
    difficulties(:medio).update!(multiplier: 1.5)

    assert_equal 225, calculate
  end

  test "el factor de tiempo nunca baja de 0,25" do
    assert_equal 50, calculate(elapsed_seconds: 10.hours.to_i)
  end

  test "la racha suma hasta un máximo de 1,5" do
    assert_equal 300, calculate(streak_days: 10)
    assert_equal 300, calculate(streak_days: 30)
  end

  test "el críptico del día vale el doble" do
    assert_equal 288, calculate(elapsed_seconds: 240, hints_used: 1, streak_days: 4, daily: true)
  end

  test "redondea al entero más cercano y da como mínimo 10" do
    calculator = ScoreCalculator.new(cryptic_type: cryptic_types(:anagrama), difficulty: difficulties(:facil),
                                     elapsed_seconds: 70, hints_used: 0, streak_days: 0)
    assert_equal 86, calculator.points # 100 × 60/70 = 85,71

    cryptic_types(:anagrama).update!(points: 10)
    assert_equal 10, calculate(elapsed_seconds: 10.hours.to_i, hints_used: 4) # daría 1
  end

  test "rechaza datos imposibles" do
    assert_raises(ArgumentError) { calculate(hints_used: 5) }
    assert_raises(ArgumentError) { calculate(elapsed_seconds: -1) }
    assert_raises(ArgumentError) { calculate(streak_days: -1) }
  end
end
