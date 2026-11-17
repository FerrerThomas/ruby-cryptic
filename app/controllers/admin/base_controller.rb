# Base de todos los controladores del backend. Exige un usuario logueado
# (lo hereda de ApplicationController a través de Authentication).
class Admin::BaseController < ApplicationController
  layout "admin"
end
