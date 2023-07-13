defmodule TodoApp.Repo do
  use Ecto.Repo,
    otp_app: :todo_app,
    adapter: Ecto.Adapters.SQLite3

  def initialize() do
    Ecto.Migrator.up(TodoApp.Repo, 20_230_713_022_845, TodoApp.Migrations.CreateTasks)
  end
end
