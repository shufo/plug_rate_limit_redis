defmodule PlugRateLimitRedisTest do
  use ExUnit.Case, async: true
  use Plug.Test
  alias PlugRateLimitRedis.RedixPool, as: Redix
  doctest PlugRateLimitRedis

  @opts RateLimit.init([interval_seconds: 30, max_requests: 20])
  @resp_body "{\"errors\":[{\"title\":\"Rate Limit exceeded\",\"detail\":\"Rate Limit exceeded\"}]}"

  setup do
    Redix.command(~w(DEL rate_limit:127.0.0.1:hello))
    Redix.command(~w(DEL rate_limit:127.0.0.1:too_many_requests))
    Redix.command(~w(DEL rate_limit:127.0.0.1:interval_seconds))
    :ok
  end

  test "Returns too many requests when rate limit is exceeded" do
    # Create a test connection
    conn = conn(:get, "/hello")

    # Invoke the plug
    conn = call(0, conn)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 429
    assert conn.resp_body == @resp_body
  end

  test "Returns too many requests when rate limit is exceeded within interval seconds" do
    # Create a test connection
    conn = conn(:get, "/too_many_requests")

    # Invoke the plug
    conn = call(0, conn, 1)

    # Assert the response and status
    assert conn.state == :sent
    assert conn.status == 429
    assert conn.resp_body == @resp_body
  end

  test "Do not return Too many requests if expire within interval seconds" do
    # Create a test connection
    conn = conn(:get, "/interval_seconds")

    # Invoke the plug
    conn = call(0, conn, 2, RateLimit.init([interval_seconds: 1, max_requests: 10]))

    # Assert the response and status
    assert conn.state == :unset
    assert conn.status == nil
    assert conn.resp_body == nil
  end

  def call(20 = _count, conn), do: conn
  def call(count, conn) do
    conn = RateLimit.call(conn, @opts)
    call(count + 1, conn)
  end
  def call(20 = _count, conn, _), do: conn
  def call(count, conn, sleep) do
    conn = RateLimit.call(conn, @opts)
    :timer.sleep(sleep * 1000)
    call(count + 1, conn, sleep)
  end
  def call(20 = _count, conn, _, _), do: conn
  def call(count, conn, sleep, opts) do
    conn = RateLimit.call(conn, opts)
    :timer.sleep(sleep * 1000)
    call(count + 1, conn, sleep)
  end

end
