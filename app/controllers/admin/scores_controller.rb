# Puntos por tipo de críptico y multiplicadores por dificultad, en una sola pantalla.
# La usan el admin y el editor de puntajes.
#
# Se guarda todo junto: si un valor es inválido no se guarda ninguno, y la página
# vuelve con los errores marcados y lo que escribió el usuario.
class Admin::ScoresController < Admin::BaseController
  allow_score_editor

  before_action :load_records

  def edit
  end

  def update
    # Solo se toman los puntos y los multiplicadores: la clave, el nombre y el
    # tiempo de referencia no se pueden cambiar desde acá aunque vengan en el pedido.
    @cryptic_types.each do |type|
      points = params.dig(:cryptic_types, type.id.to_s, :points)
      type.points = points unless points.nil?
    end
    @difficulties.each do |difficulty|
      multiplier = params.dig(:difficulties, difficulty.id.to_s, :multiplier)
      difficulty.multiplier = multiplier unless multiplier.nil?
    end

    if save_all
      redirect_to edit_admin_scores_path, notice: "Puntajes guardados. Se aplican a las partidas que se resuelvan a partir de ahora."
    else
      flash.now[:alert] = "No se guardó ningún cambio: revisá los valores marcados en rojo."
      render :edit, status: :unprocessable_content
    end
  end

  private
    def load_records
      @cryptic_types = CrypticType.ordered.to_a
      @difficulties = Difficulty.ordered.to_a
    end

    def save_all
      records = @cryptic_types + @difficulties
      return false unless records.map(&:valid?).all?

      ActiveRecord::Base.transaction { records.each(&:save!) }
      true
    end
end
