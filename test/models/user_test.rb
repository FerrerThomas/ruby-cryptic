require "test_helper"

class UserTest < ActiveSupport::TestCase
  def build_user(**attrs)
    User.new({ email_address: "nuevo@example.com", password: "secreta123" }.merge(attrs))
  end

  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "por defecto es editor de puntajes y está activo" do
    user = build_user

    assert user.valid?
    assert user.score_editor?
    assert user.active?
  end

  test "el email es obligatorio, único y con formato válido" do
    assert_not build_user(email_address: "").valid?
    assert_not build_user(email_address: "no-es-un-email").valid?
    assert_not build_user(email_address: "ONE@example.com").valid?
  end

  test "el rol tiene que ser uno de los definidos" do
    user = build_user(role: "superusuario")

    assert_not user.valid?
    assert user.errors.of_kind?(:role, :inclusion)
  end

  test "la base rechaza un rol inválido aunque se saltee la validación" do
    assert_raises(ActiveRecord::StatementInvalid) do
      users(:one).update_column(:role, "superusuario")
    end
  end

  test "scope active excluye a los desactivados" do
    assert_includes User.active, users(:one)
    assert_not_includes User.active, users(:inactive)
  end
end
