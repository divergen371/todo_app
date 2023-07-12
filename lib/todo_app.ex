defmodule TodoApp do
  @moduledoc """
  TodoApp keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  use Application

  def config_dir() do
    Path.join([Desktop.OS.home(), ".config", "todo_app"])
  end

  @app Mix.Project.config()[:app]
  def start(:normal, []) do
    # configフォルダを掘る
    File.mkdir_p!(config_dir)

    # DBの場所を指定
    Application.put_env(:todo_app, TodoApp.Repo,
      database: Path.join(config_dir(), "/database.sq3")
    )

    # session用のETSを起動
    :session = :ets.new(:session, [:named_table, :public, read_concurrency: true])

    children = [
      TodoApp.Repo,
      {Phoenix.PubSub, name: TodoApp.PubSub},
      TodoAppWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: TodoApp.Supervisor]
    # メインのスーパーバイザーを起動
    {:ok, sup} = Supervisor.start_link(children, opts)

    # DBのマイグレーションを実行
    TodoApp.Repo.initialize()

    # Phoenixサーバーが起動中のポート番号を取得するための
    port = :ranch.get_port(TodoAppWeb.Endpoint.HTTP)

    # メインのスーパーバイザーのは以下にElixirDesktopのスーパーバイザーを追加する
    {:ok, _} =
      Supervisor.start_child(sup, {
        Desktop.Window,
        [
          app: @app,
          id: TodoAppWindow,
          title: "TodoApp",
          size: {400, 800},
          url: "http://localhost:#{port}"
        ]
      })
  end
end
