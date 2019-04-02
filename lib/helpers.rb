
# Sets local env configurations if applicable
def set_env_configs
  return false if Sinatra::Base.production?

  set :port, 9494
  require 'dotenv'
  Dotenv.load 'config/local_vars.env'
end

# Gets env-specific Redis object
def get_redis_object
  redis = nil
  if Sinatra::Base.production?
    configure do
      uri = URI.parse(ENV['REDISTOGO_URL'])
      redis = Redis.new(host: uri.host, port: uri.port, password: uri.password)
    end
  else
    redis = Redis.new
  end
  redis.flushall
  redis
end

# Prepends new Tweet's HTML to each follower's cached timeline
# if already cached.
def fanout_to_cache(tweet, author)
  new_html = "<li>#{tweet.body}<br/>-#{tweet.author_handle} at #{tweet.created_on}</li>"
  author.follows_to_me.each do |f|
    redis_key = "#{f.follower_id}:timeline_html"
    if REDIS.exists(redis_key)
      puts "\nAdding HTML to #{f.follower_id}\n"
      timeline_html = REDIS.get(redis_key)
      REDIS.set(redis_key, new_html + timeline_html)
    end
  end
end
