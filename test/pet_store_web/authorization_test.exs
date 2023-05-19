defmodule PetStoreWeb.AuthorizationTest do
  use PetStoreWeb.ConnCase, async: true

  alias PetStoreWeb.Authorization
  import PetStore.AccountsFixtures

  setup do
    user = user_fixture()
    admin = user_fixture(admin_level: 1)
    admin1_2 = user_fixture(admin_level: 1)
    admin2 = user_fixture(admin_level: 2)

    %{user: user, admin: admin, admin1_2: admin1_2, admin2: admin2}
  end

  describe ":update_email" do
    test "authorizes if same user", %{user: user} do
      assert Bodyguard.permit?(Authorization, :update_email, user, user)
    end

    test "authorizes if higher admin", %{admin: lower, admin2: higher} do
      assert Bodyguard.permit?(Authorization, :update_email, higher, lower)
    end

    test "doesn't authorize if same or lower admin", %{
      admin: admin,
      admin1_2: other_admin,
      admin2: higher
    } do
      refute Bodyguard.permit?(Authorization, :update_email, admin, other_admin)
      refute Bodyguard.permit?(Authorization, :update_email, admin, higher)
    end
  end
end
