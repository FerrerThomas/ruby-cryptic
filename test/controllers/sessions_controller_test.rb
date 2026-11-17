require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = users(:one) }

  test "new" do
    get new_session_path
    assert_response :success
    assert_select "h1", "Iniciar sesión"
  end

  test "create with valid credentials" do
    post session_path, params: { email_address: @user.email_address, password: "password" }

    assert_redirected_to admin_root_path
    assert cookies[:session_id]
  end

  test "un editor de puntajes también puede ingresar" do
    post session_path, params: { email_address: users(:two).email_address, password: "password" }

    assert_redirected_to admin_root_path
    assert cookies[:session_id]
  end

  test "create with invalid credentials" do
    post session_path, params: { email_address: @user.email_address, password: "wrong" }

    assert_redirected_to new_session_path
    assert_nil cookies[:session_id]
    follow_redirect!
    assert_select ".alert-danger", "Email o contraseña incorrectos."
  end

  test "un usuario desactivado no puede ingresar aunque la contraseña sea correcta" do
    assert_no_difference -> { Session.count } do
      post session_path, params: { email_address: users(:inactive).email_address, password: "password" }
    end

    assert_redirected_to new_session_path
    assert_nil cookies[:session_id]
    follow_redirect!
    assert_select ".alert-danger", "Email o contraseña incorrectos."
  end

  test "si desactivan al usuario, su sesión abierta deja de valer" do
    sign_in_as(@user)
    @user.update!(active: false)

    get admin_root_path

    assert_redirected_to new_session_path
  end

  test "destroy" do
    sign_in_as(@user)

    delete session_path

    assert_redirected_to new_session_path
    assert_empty cookies[:session_id]
  end
end
