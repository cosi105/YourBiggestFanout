require 'sinatra'
require 'nt_models'
require 'activerecord-import'

unless Sinatra::Base.production?
  set :port, 9494
  require 'pry-byebug'
end

post '/new_tweet/:id' do
  t = Tweet.find(params[:id])
  author = t.author
  mapped = author.follows_to_me.map { |f| [f.follower_id, t.id, t.body, t.created_on, t.author_handle] }
  import_timeline_pieces(mapped)
  status 200
end

post '/new_follower/:followee_id/:follower_id' do
  followee_tweets = Tweet.where(author_id: params[:followee_id])
  follower_id = params[:follower_id]
  mapped = followee_tweets.map { |t| [follower_id, t.id, t.body, t.created_on, t.author_handle] }
  import_timeline_pieces(mapped)
  status 200
end

def import_timeline_pieces(pieces)
  columns = %i[timeline_owner_id tweet_id tweet_body tweet_created_on tweet_author_handle]
  TimelinePiece.import columns, pieces
end
