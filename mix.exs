defmodule Sable.MixProject do
  use Mix.Project

  def project do
    [
      app: :sable,
      version: "0.1.0",
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      compilers: [:phoenix_live_view] ++ Mix.compilers(),
      listeners: [Phoenix.CodeReloader],
      test_coverage: [tool: ExCoveralls],
      dialyzer: [plt_file: {:no_warn, "priv/plts/project.plt"}],
      excoveralls: [threshold: 80],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        "coveralls.cobertura": :test
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Sable.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  def cli do
    [
      preferred_envs: [precommit: :test]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      # Phoenix
      {:phoenix, "~> 1.8.1"},
      {:phoenix_ecto, "~> 4.5"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 1.1.0"},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:dns_cluster, "~> 0.2.0"},
      # Frontend
      {:tailwind, "~> 0.3", runtime: Mix.env() == :dev},
      {:esbuild, "~> 0.10", runtime: Mix.env() == :dev},
      {:live_select, "~> 1.0"},
      {:contex, "~> 0.5.0"},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.2.0",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},
      # HTTP
      {:bandit, "~> 1.5"},
      {:req, "~> 0.5"},
      # JSON
      {:jason, "~> 1.2"},
      # Mailer
      {:swoosh, "~> 1.16"},
      # I18n
      {:gettext, "~> 0.26"},
      # DB
      {:postgrex, ">= 0.0.0"},
      {:ecto_sql, "~> 3.13"},
      {:bcrypt_elixir, "~> 3.0"},
      # Authorization
      {:bodyguard, "~> 2.4"},
      # CORS
      {:cors_plug, "~> 3.0"},
      # Metrics
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      # Linters
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:sobelow, "~> 0.13", only: [:dev, :test], runtime: false},
      {:mix_audit, "~> 2.1", only: [:dev, :test], runtime: false},
      # Tests
      {:faker, "~> 0.19.0-alpha.1", only: [:dev, :test]},
      {:ex_machina, "~> 2.8.0", only: :test},
      {:excoveralls, "~> 0.18", only: :test},
      {:lazy_html, ">= 0.1.0", only: :test}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["compile", "tailwind sable", "esbuild sable"],
      "assets.deploy": [
        "tailwind sable --minify",
        "esbuild sable --minify",
        "phx.digest"
      ],
      precommit: ["compile --warning-as-errors", "deps.unlock --unused", "format", "test"],
      cover: ["coveralls.html"],
      lint: [
        "dialyzer --format github --format dialyxir",
        "format --dry-run --check-formatted",
        "credo --strict",
        "deps.unlock --check-unused",
        "deps.audit",
        "sobelow -i Config.HTTPS"
      ]
    ]
  end
end
