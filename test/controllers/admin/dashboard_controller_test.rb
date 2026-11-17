require "test_helper"

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  test "sin sesión redirige al login" do
    get admin_root_path

    assert_redirected_to new_session_path
  end

  test "con sesión muestra el panel" do
    sign_in_as(users(:one))

    get admin_root_path

    assert_response :success
    assert_select "h1", "Panel de administración"
  end
end
