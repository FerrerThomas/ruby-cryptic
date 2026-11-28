module AdminNavigationHelper
  # Link del menú del backend. Queda resaltado cuando se está en ese controlador.
  #
  #   <%= admin_nav_link "Puntajes", edit_admin_scores_path, icon: "trophy", controller: "scores" %>
  #
  # `icon` es un nombre de Bootstrap Icons (https://icons.getbootstrap.com) sin el prefijo "bi-".
  def admin_nav_link(label, path, icon:, controller:)
    active = controller_path == "admin/#{controller}"

    link_to path, class: class_names("admin-nav__link", "is-active": active), aria: { current: (active ? "page" : nil) } do
      safe_join([ tag.i(class: "bi bi-#{icon}", aria: { hidden: true }), tag.span(label) ])
    end
  end
end
