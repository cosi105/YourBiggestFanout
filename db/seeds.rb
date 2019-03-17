def get_csv(model)
  CSV.read("#{ENV['APP_ROOT']}/db/seed_files/#{model}.csv")
end

def load_seed(model_params, model_class)
  i = 0
  size = model_params.size
  class_name = model_class.name
  model_params.each do |params|
    model_class.new(params).save(validate: false)
    puts "#{class_name} #{i += 1} / #{size}"
  end
end

require 'csv'
user_rows = get_csv('users')
tweet_rows = get_csv('tweets')
follow_rows = get_csv('follows')
timeline_piece_rows = get_csv('timeline_pieces')

mapped_user_rows = user_rows.map { |row| {id: row[0], name: row[1], handle: "@#{row[1] << row[0]}".downcase, password: "@#{row[1] << row[0]}".downcase} }

mapped_follow_rows = follow_rows.map { |row| { follower_id: row[0], followee_id: row[1] }}

mapped_tweet_rows = tweet_rows.map { |row| { author_id: row[0], body: row[1], created_on: DateTime.strptime(row[2], '%Y-%m-%d %H:%M:%S %z') } }

mapped_timeline_piece_rows = timeline_piece_rows.map { |row| { timeline_owner_id: row[0], tweet_id: row[1] } }

[[mapped_user_rows, User], [mapped_tweet_rows, Tweet], [mapped_follow_rows, Follow], [mapped_timeline_piece_rows, TimelinePiece]].each { |arr| load_seed(arr[0], arr[1]) }

User.create(id: User.last.id + 1, name: 'testuser', handle: 'testuser@sample.com', password: 'password')
