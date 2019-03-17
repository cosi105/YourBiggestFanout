describe 'POST on /login' do
  it 'can authenticate a user' do
    post "#{API_PATH}/login", handle: '@ari', password: 'ari123'
    last_response.status.must_equal 201
  end

  it 'can lock out a hacker' do
    post "#{API_PATH}/login", handle: '@ari', password: 'iamhackerman'
    last_response.status.must_equal 401
  end
end

describe 'POST on /signup' do
  it 'can register a new user' do
    old_count = User.count
    post "#{API_PATH}/signup", name: 'New User', handle: '@newuser', password: 'hey_im_new_here'
    last_response.status.must_equal 201
    User.count.must_equal old_count + 1
  end

  it 'will not register a duplicate user' do
    old_count = User.count
    post "#{API_PATH}/signup", name: @ari.name, handle: @ari.handle, password: 'this_twitter_aint_big_enough_for_two_of_us'
    last_response.status.must_equal 403
    User.count.must_equal old_count
  end
end

describe 'protected routes' do
  it 'will not allow access to protected routes' do
    protected_gets = [
      'users/profile',
      '/users/followers',
      '/users/following',
      '/users/unfollowing',
      '/tweets/new',
      '/tweets',
      '/protected'
    ]

    protected_gets.each do |route|
      get route
      last_response.status.must_equal 302
    end

    post '/users/following', name: 'Ari'
    last_response.status.must_equal 302
  end
end
