defmodule PetStore.Repo.Migrations.AddAdminLevelToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :admin_level, :integer, null: false, default: 0
    end

    create constraint(:users, :admin_level_range, check: "admin_level >= 0 AND admin_level <= 5")
  end
end
