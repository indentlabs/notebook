require "redis-client"

RedisClient.configure do |config|
  # Force RESP2 for compatibility with older Redis versions (pre-Redis 6)
  # that don't support the HELLO command.
  # We can remove this once we're using Redis 6 or higher (server version).
  config.resp_version = 2
end 