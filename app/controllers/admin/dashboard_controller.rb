class Admin::DashboardController < Admin::BaseController
  # Es la página de inicio del backend para todos los roles (y adonde se redirige
  # cuando alguien no tiene permiso), así que la ve también el editor de puntajes.
  allow_score_editor

  def index
  end
end
