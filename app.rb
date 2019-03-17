require 'sinatra'
require 'sinatra/flash'
require 'nt_models'
require 'activerecord-import'

set :port, 9494

unless Sinatra::Base.production?
  require 'pry-byebug'
end

post '/new_tweet/:id' do
  id = params[:id]
  author = Tweet.find(id).author
  import_timeline_pieces(author.follows_to_me.map { |f| [f.follower_id, id] })
  status 200
end

post '/new_follower/:followee_id/:follower_id' do
  followee_tweets = Tweet.where(author_id: params[:followee_id])
  follower_id = params[:follower_id]
  import_timeline_pieces(followee_tweets.map { |t| [follower_id, t.id] })
  status 200
end

def import_timeline_pieces(pieces)
  columns = %i[timeline_owner_id tweet_id]
  TimelinePiece.import columns, pieces
end
