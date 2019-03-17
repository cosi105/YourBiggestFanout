describe 'POST on /tweets/new' do
  it 'can post a new tweet' do
    post "/login", handle: '@ari', password: 'ari123'
    post "#{API_PATH}/tweets/new", tweet: { body: 'Scalability is fun!' }
    last_response.status.must_equal 201
  end

  it 'will not post a new tweet without authentication' do
    post "#{API_PATH}/tweets/new", tweet: { body: 'Scalability is fun!' }
    last_response.status.must_equal 401
  end

  it 'can get hashtags and mentions' do
    set_new_tweet(@ari.id, '@brad isnt #scalability the #best thing ever?')
    tweet = @ari.tweets.last
    tweet.mentions.count.must_equal 1
    tweet.mentions.first.mentioned_user.must_equal @brad
    tweet.hashtags.count.must_equal 2
    tweet.hashtags.first.name.must_equal '#scalability'
    tweet.hashtags.second.name.must_equal '#best'
  end
end
