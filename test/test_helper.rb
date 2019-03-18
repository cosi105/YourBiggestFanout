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
  end

  it 'can fanout tweets' do
    [@brad, @yang, @pito].each { |u| u.followees << @ari }
    tweet = Tweet.create(author: @ari, body: 'I <3 Scalability')
    post "/new_tweet/#{tweet.id}"
    [@brad, @yang, @pito].each do |u|
      u.timeline_tweets.count.must_equal 1
      u.timeline_tweets.first.must_equal tweet
    end
  end

  it 'can distribute tweets to new followers' do
    tweet = Tweet.create(author: @ari, body: 'I <3 Scalability')
    [@brad, @yang, @pito].each do |u|
      post "/new_follower/#{@ari.id}/#{u.id}"
      u.timeline_tweets.count.must_equal 1
      u.timeline_tweets.first.must_equal tweet
    end
  end
end
