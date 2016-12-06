defmodule RateLimit do
  import Plug.Conn
  alias PlugRateLimitRedis.RedixPool, as: Redix

  def init(options), do: options

  def call(conn, options) do
    with false <- testing?,
         true  <- available?(conn, options)
    do
      conn
    else
      false -> render_error(conn)
      _     -> render_error(conn)
    end
  end

  @shortdoc "Disable rate limit while testing"
  defp testing? do
    case Mix.env do
      :test -> true
      _     -> false
    end
  end

  @shortdoc "Check if the rate limit is exceeded"
  defp available?(conn, options) do
    interval_seconds = options[:interval_seconds] || -1
    max_requests = options[:max_requests]
    bucket_name = options[:bucket_name] || bucket_name(conn)

    {:ok, count} = Redix.command(~w(INCR #{bucket_name}))
    Redix.command(~w(EXPIRE #{bucket_name} #{interval_seconds}))

    count < max_requests
  end

  defp bucket_name(conn) do
    "rate_limit:#{ip(conn)}:#{path(conn)}"
  end

  defp ip(conn) do
    conn.remote_ip |> Tuple.to_list |> Enum.join(".")
  end

  defp path(conn) do
    Enum.join(conn.path_info, "/")
  end

  defp render_error(conn) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(:too_many_requests, "{\"errors\":[{\"title\":\"Rate Limit exceeded\",\"detail\":\"Rate Limit exceeded\"}]}")
    |> halt # Stop execution of further plugs, return response now
  end
end
