defmodule SlimPickens.MixProject do
  use Mix.Project

  def project do
    [
      app: :slim_pickens,
      version: "0.1.1-pre",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      preferred_cli_env: [release: :prod],
      releases: [
        slim: [
          steps: [:assemble, &Bakeware.assemble/1],
          strip_beams: [keep: ["Docs"]]
        ]
      ]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    if Mix.env() == :test || Mix.env() == :dev do
      [
        extra_applications: [:logger]
      ]
    else
      [
        extra_applications: [:logger],
        mod: {SlimPickens.Application, [env: Mix.env()]}
      ]
    end
  end

  defp deps do
    [
      {:prompt, "~> 0.5.11"},
      {:bakeware, "~> 0.2.0", runtime: false},
      {:dialyxir, "~> 1.1", only: [:dev], runtime: false},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false}
    ]
  end
end
