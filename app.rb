require 'sinatra'
require 'nt_models'
require 'activerecord-import'
require 'redis'
require 'open-uri'

ENV['APP_ROOT'] = settings.root
Dir["#{ENV['APP_ROOT']}/lib/*.rb"].each { |file| require file }
set_env_configs
REDIS = get_redis_object

# # Adds new Tweet to Follower's Redis timeline cache
# def cache_tweet(follower_id, tweet)
#   size_key = "#{follower_id}:timeline_size"
#   if REDIS.exists(size_key) # Only update if already cached
#     timeline_size = REDIS.incr(size_key) # Update timeline size
#     REDIS.hmset( # Insert new Tweet
#       "#{follower_id}:#{timeline_size}",
#       'id', tweet.id,
#       'body', tweet.body,
#       'created_on', tweet.created_on,
#       'author_handle', tweet.author_handle
#     )
#   end
# end

post '/new_tweet/:id' do
  t = Tweet.find(params[:id])
  author = t.author
  Thread.new { fanout_to_cache(t, author) } # Update cached timelines
  mapped = author.follows_to_me.map do |f|
    [f.follower_id, t.id, t.body, t.created_on, t.author_handle]
  end
  import_timeline_pieces(mapped)
  status 200
end

post '/new_follower/:followee_id/:follower_id' do
  followee_tweets = Tweet.where(author_id: params[:followee_id])
  follower_id = params[:follower_id]
  mapped = followee_tweets.map do |t|
    [follower_id, t.id, t.body, t.created_on, t.author_handle]
  end
  import_timeline_pieces(mapped)
  status 200
end

def import_timeline_pieces(pieces)
  columns = %i[timeline_owner_id tweet_id tweet_body tweet_created_on tweet_author_handle]
  TimelinePiece.import columns, pieces
end
