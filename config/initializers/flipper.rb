Flipper.configure do |config|
  config.default do
    # Store feature flag states in Redis so it persists across server reboots
    adapter = if Rails.env.production?
      client = Redis.new(:url => ENV[ENV["REDIS_PROVIDER"]])
      Flipper::Adapters::Redis.new(client)
    else
      Flipper::Adapters::Memory.new
    end

    # pass adapter to handy DSL instance
    Flipper.new(adapter)
  end
end