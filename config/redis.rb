uri   = URI.parse(REDIS_URL)
REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)