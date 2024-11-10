require 'net/http'

def create_post(login, title, body, ip)
  uri = URI("http://localhost:3000/api/v1/posts")
  http = Net::HTTP.new(uri.host, uri.port)

  request = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json' })
  request.body = {
    user: {
      login: login
    },
    title: title,
    body: body,
    ip: ip
  }.to_json

  http.request(request)
end

def create_rating(post_id, user_id)
  value = [1, 2, 3, 4, 5].sample

  uri = URI("http://localhost:3000/api/v1/ratings")
  http = Net::HTTP.new(uri.host, uri.port)

  request = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json' })
  request.body = {
    post_id: post_id,
    user_id: user_id,
    value: value
  }.to_json

  http.request(request)
end

puts 'Cleaning up the database'
  Rating.delete_all
  Post.delete_all
  User.delete_all
puts 'Database cleaned up'

puts 'Creating Users and Posts via API'

ips = 50.times.map { Faker::Internet.ip_v4_address }
users = []
created_posts = 0
posts_to_create = 200_000

Parallel.each(1..100, in_threads: 30) do |i|
  login = Faker::Internet.unique.username
  users << login
end

puts "#{users.size} users created at #{Time.zone.now}."

unique_titles = Array.new(2000) { Faker::Lorem.sentence(word_count: 3) }
unique_bodies = Array.new(2000) { Faker::Lorem.paragraph }

posts = Array.new(posts_to_create) do
  {
    login: users.sample,
    title: unique_titles.sample,
    body: unique_bodies.sample,
    ip: ips.sample
  }  
end

batch_size = 500

Parallel.each(posts.in_groups_of(batch_size, false), in_threads: 30) do |batch|
  batch.each do |post|
    response = create_post(post[:login], post[:title], post[:body], post[:ip])
    created_posts += 1 if response.is_a?(Net::HTTPSuccess)
    
  end

  puts "#{created_posts}/#{posts_to_create} posts created at #{Time.zone.now}" if created_posts % (10 * batch_size) == 0
end

puts "#{Post.count} posts created successfully via API!"

puts 'Creating Ratings'

total_posts = Post.count
ratings_to_create = (total_posts * 0.75).to_i
posts_to_rate = Post.order("RANDOM()").limit(ratings_to_create)
created_ratings = 0

Parallel.each(posts_to_rate.in_groups_of(batch_size, false), in_threads: 30) do |batch|
  batch.each do |post|
    user_id = User.pluck(:id).sample
    response = create_rating(post.id, user_id)
    
    created_ratings += 1 if response.is_a?(Net::HTTPSuccess)
  end

  puts "#{created_ratings}/#{ratings_to_create} ratings created at #{Time.zone.now}" if created_ratings % (10 * batch_size) == 0
end

puts "#{User.count} users, #{Post.count} posts, #{Rating.count} ratings have been created at #{Time.zone.now} successfully via API!"