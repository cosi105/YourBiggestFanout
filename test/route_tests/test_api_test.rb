describe 'POST on /test/reset/all' do
  it 'Should reset all data' do
    post '/test/reset/all'

    last_response.ok?
    User.count.must_equal(1001)
    Follow.count.must_equal(4909)
    Tweet.count.must_equal(100175)
  end
end

describe 'POST on /test/reset' do
  it 'Should reset n users and m tweets' do
    post '/test/reset', users: 20, tweets: 20

    last_response.ok?
    User.count.must_equal(21)
    Tweet.count.must_equal(20)
  end
end

describe 'POST /test/user/:userid/tweets' do
  it 'Should create n tweets for a user' do
    delete_all
    seed_testuser
    post '/test/user/1/tweets', count: 40

    last_response.ok?
    Tweet.count.must_equal(40)
  end
end

describe 'Test status report' do
  it 'Can get data about the state of the app' do
    post '/test/reset/all'
    load_status
    @user_num.must_equal User.count
    @follow_num.must_equal Follow.count
    @tweet_num.must_equal Tweet.count
    @testuser_id.must_equal User.find_by(handle: 'testuser@sample.com').id
  end
end
