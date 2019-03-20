# This file is a DRY way to set all of the requirements
# that our tests will need, as well as a before statement
# that purges the database and creates fixtures before every test

ENV['APP_ENV'] = 'test'
require 'simplecov'
SimpleCov.start
require 'minitest/autorun'
require 'rack/test'
require_relative '../app'

def app
  Sinatra::Application
end

describe 'NanoTwitter' do
  include Rack::Test::Methods
  before do
    ActiveRecord::Base.subclasses.each(&:delete_all)
    names = %w[ari brad yang pito]
    users = names.map { |s| User.create(name: s.capitalize, handle: "@#{s}", password: "#{s}123") }
    @ari, @brad, @yang, @pito = users
    @tweet = Tweet.new(author: @ari, body: 'I <3 Scalability', created_on: Time.now, author_handle: @ari.handle)
  end

  it 'can fanout tweets' do
    [@brad, @yang, @pito].each { |u| u.followees << @ari }
    @tweet.save
    post "/new_tweet/#{@tweet.id}"
    [@brad, @yang, @pito].each do |u|
      u.timeline_pieces.count.must_equal 1
      t = u.timeline_pieces.first
      t.tweet.must_equal @tweet
      t.tweet_body.must_equal @tweet.body
      t.tweet_created_on.must_equal @tweet.created_on
      t.tweet_author_handle.must_equal @tweet.author.handle
    end
  end

  it 'can distribute tweets to new followers' do
    @tweet.save
    [@brad, @yang, @pito].each do |u|
      post "/new_follower/#{@ari.id}/#{u.id}"
      u.timeline_pieces.count.must_equal 1
      t = u.timeline_pieces.first
      t.tweet.must_equal @tweet
      t.tweet_body.must_equal @tweet.body
      t.tweet_created_on.must_equal @tweet.created_on
      t.tweet_author_handle.must_equal @tweet.author.handle
    end
  end
end
