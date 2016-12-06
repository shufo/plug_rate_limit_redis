defmodule PlugRateLimitRedis.Mixfile do
  use Mix.Project

  def project do
    [app: :plug_rate_limit_redis,
     version: "0.1.0",
     elixir: "~> 1.3",
     description: description,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     package: package,
     deps: deps()]
  end

  defp description do
    """
    An Elixir plug rate limiting with redis.
    """
  end

  def application do
    [mod: {PlugRateLimitRedis, []}, applications: [:logger]]
  end

  defp deps do
    [{:redix, ">= 0.0.0"},
     {:cowboy, "~> 1.0.0"},
     {:plug, "~> 1.0"},
     {:ex_doc, ">= 0.0.0", only: :dev},
    ]
  end

  defp package do
    [name: :plug_rate_limit_redis,
     files: ["lib", "config", "mix.exs", "README*"],
     maintainers: ["Shuhei Hayashibara"],
     licenses: ["MIT"],
     links: %{github: "https://github.com/shufo/plug_rate_limit_redis"}]
  end
end
