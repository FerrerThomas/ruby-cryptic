# Calcula los puntos de un críptico resuelto, según el enunciado:
#
#   puntos = base × tiempo × pistas × racha (× 2 si es el críptico del día)
#
# - base   = puntos del tipo × multiplicador de la dificultad (desde la configuración, #5)
# - tiempo = 1 si resolvió dentro del tiempo de referencia; si no, referencia ÷ tiempo (mínimo 0,25)
# - pistas = 1 − 0,20 × pistas usadas
# - racha  = 1 + 0,05 × días de racha contando hoy (máximo 1,5)
# - Se redondea al entero más cercano y un críptico resuelto da como mínimo 10 puntos.
# - Rendirse da 0 puntos: en ese caso no se usa el calculador (ver SURRENDER_POINTS).
#
# Las cuentas se hacen con Rational para no arrastrar errores de punto flotante
# (200 × 0,75 × 0,8 × 1,2 da exactamente 144).
#
# Uso (la partida guarda el resultado al resolverse, así que cambios posteriores
# en la configuración no recalculan partidas ya jugadas):
#
#   ScoreCalculator.call(
#     cryptic_type: cryptic.cryptic_type,
#     difficulty: cryptic.difficulty,
#     elapsed_seconds: game.solved_at - game.started_at,
#     hints_used: game.hints_used,
#     streak_days: streak_days_including_today,
#     daily: cryptic_of_the_day?
#   ) # => 144
#
# Para mostrar el detalle de la cuenta: ScoreCalculator.new(...) y leer los factores.
class ScoreCalculator
  MIN_POINTS = 10
  SURRENDER_POINTS = 0

  MIN_TIME_FACTOR = Rational(1, 4)
  HINT_PENALTY = Rational(1, 5)
  MAX_HINTS = 4
  STREAK_BONUS_PER_DAY = Rational(1, 20)
  MAX_STREAK_FACTOR = Rational(3, 2)
  DAILY_FACTOR = 2

  attr_reader :cryptic_type, :difficulty, :elapsed_seconds, :hints_used, :streak_days

  def self.call(**args)
    new(**args).points
  end

  def initialize(cryptic_type:, difficulty:, elapsed_seconds:, hints_used:, streak_days:, daily: false)
    @cryptic_type = cryptic_type
    @difficulty = difficulty
    @elapsed_seconds = elapsed_seconds.to_r
    @hints_used = Integer(hints_used)
    @streak_days = Integer(streak_days)
    @daily = daily

    validate_arguments!
  end

  def points
    raw = base * time_factor * hints_factor * streak_factor * daily_factor
    [ raw.round, MIN_POINTS ].max
  end

  def base
    cryptic_type.points * difficulty.multiplier.to_r
  end

  def time_factor
    reference = difficulty.reference_seconds
    return 1 if elapsed_seconds <= reference

    [ reference / elapsed_seconds, MIN_TIME_FACTOR ].max
  end

  def hints_factor
    1 - HINT_PENALTY * hints_used
  end

  def streak_factor
    [ 1 + STREAK_BONUS_PER_DAY * streak_days, MAX_STREAK_FACTOR ].min
  end

  def daily_factor
    daily? ? DAILY_FACTOR : 1
  end

  def daily?
    @daily
  end

  private
    def validate_arguments!
      raise ArgumentError, "elapsed_seconds no puede ser negativo" if elapsed_seconds.negative?
      raise ArgumentError, "hints_used tiene que estar entre 0 y #{MAX_HINTS}" unless hints_used.between?(0, MAX_HINTS)
      raise ArgumentError, "streak_days no puede ser negativo" if streak_days.negative?
    end
end
