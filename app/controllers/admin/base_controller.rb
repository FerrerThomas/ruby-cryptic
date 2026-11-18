# Base de todos los controladores del backend.
#
# - Exige un usuario logueado (lo hereda de ApplicationController a través de Authentication).
# - Por defecto, SOLO los administradores pueden entrar. Un controlador que también
#   tenga que usar el editor de puntajes lo habilita explícitamente:
#
#     class Admin::ScoresController < Admin::BaseController
#       allow_score_editor
#     end
#
#   Se puede limitar a algunas acciones: `allow_score_editor only: %i[ index edit update ]`.
#
# Así, si un editor de puntajes escribe a mano la URL de una pantalla que no le
# corresponde, el servidor lo rechaza aunque el link no aparezca en el menú.
class Admin::BaseController < ApplicationController
  layout "admin"

  before_action :require_admin!

  class << self
    def allow_score_editor(**options)
      skip_before_action :require_admin!, **options
    end
  end

  private
    def require_admin!
      return if Current.user&.admin?

      redirect_to admin_root_path, alert: "No tenés permiso para entrar a esa sección."
    end
end
