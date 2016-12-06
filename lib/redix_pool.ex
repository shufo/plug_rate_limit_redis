defmodule PlugRateLimitRedis.RedixPool do
  use Supervisor

  @pool_size 20
  @host Application.get_env(:plug_rate_limit_redis, :host)
  @port Application.get_env(:plug_rate_limit_redis, :port)

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    redix_workers = for i <- 0..(@pool_size - 1) do
      worker(Redix, [[host: @host, port: @port], [name: :"redix_#{i}"]], id: {Redix, i})
    end

    supervise(redix_workers, strategy: :one_for_one, name: __MODULE__)
  end

  def command(command) do
    Redix.command(:"redix_#{random_index()}", command)
  end

  defp random_index() do
    rem(System.unique_integer([:positive]), @pool_size)
  end
end
