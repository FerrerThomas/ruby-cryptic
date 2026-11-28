# Configuración general del juego: URL de la fuente de crípticos y texto de bienvenida.
# Solo para admins (no tiene allow_score_editor): si el editor de puntajes entra
# escribiendo la URL a mano, Admin::BaseController lo rechaza.
class Admin::SettingsController < Admin::BaseController
  before_action :set_setting

  def edit
  end

  def update
    if @setting.update(setting_params)
      redirect_to edit_admin_settings_path, notice: "Configuración guardada."
    else
      flash.now[:alert] = "No se guardaron los cambios: revisá los campos marcados en rojo."
      render :edit, status: :unprocessable_content
    end
  end

  private
    def set_setting
      @setting = Setting.current
    end

    def setting_params
      params.expect(setting: %i[ cryptics_source_url welcome_text ])
    end
end
