[![Build Status](https://travis-ci.org/shufo/plug_rate_limit_redis.svg?branch=master)](https://travis-ci.org/shufo/plug_rate_limit_redis)
[![hex.pm version](https://img.shields.io/hexpm/v/plug_rate_limit_redis.svg)](https://hex.pm/packages/plug_rate_limit_redis)
[![hex.pm](https://img.shields.io/hexpm/l/plug_rate_limit_redis.svg)](https://github.com/shufo/plug_rate_limit_redis/blob/master/LICENSE)

# plug_rate_limit_redis

An Elixir plug that rate limiting with redis.

## Overview

In Elixir, since ETS is provided by Erlang runtime, it can process rate limit count within memory, but in real world there is no guarantee that it will not restart every time it is deployed and sometimes you want to share values with multiple servers I guess.

So I decided to allow Rate Limit with Redis, even if I restarted the Erlang runtime every deployment, I also made it possible to handle from multiple servers.

## Installation

1. Add `plug_rate_limit_redis` to your list of dependencies in `mix.exs`:

  ```elixir
  def deps do
    [{:plug_rate_limit_redis, "~> 0.1.0"}]
  end
  ```

2. Ensure `plug_rate_limit_redis` is started before your application:

  ```elixir
  def application do
    [applications: [:plug_rate_limit_redis]]
  end
  ```

## Usage

- Configure your `config.ex`

```elixir
config :plug_rate_limit_redis,
  host: "localhost", # Redis host
  port: 6379
```

- Add the RateLimit plug to the controller for which you want rate limit.

```elixir
plug RateLimit, interval_seconds: 60, max_requests: 30
```

- If you want to restrict the action, please do as follows

```elixir
plug RateLimit, [interval_seconds: 60, max_requests: 30] when action in [:index, :show:, :update]
```

- Or add it to pipeline with router

```elixir
pipeline :rate_limit do
  plug RateLimit, interval_seconds: 60, max_requests: 30
end

scope "/" do
  pipe_through :rate_limit
  get "/v1/foo/bar, FooController, :bar
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
