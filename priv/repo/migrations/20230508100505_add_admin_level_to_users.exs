defmodule PetStore.Repo.Migrations.AddAdminLevelToUsers do
  use Ecto.Migration

  def up do
    alter table(:users) do
      add_if_not_exists :admin_level, :integer, null: false, default: 0
    end

    create constraint(:users, :admin_level_range, check: "admin_level >= 0 AND admin_level <= 5")
  end

  def down do
    drop constraint(:users, :admin_level_range)

    alter table(:users) do
      remove_if_exists :admin_level, :integer
    end
  end
end
