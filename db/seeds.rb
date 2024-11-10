require 'net/http'
require 'json'
require 'parallel'

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

puts 'Creating Users and Posts via API'

ips = 50.times.map { Faker::Internet.ip_v4_address }
users = []
created_posts = 0
posts_to_create = 200_000

Parallel.each(1..100, in_threads: 10) do |i|
  login = Faker::Internet.unique.username
  users << login
end

puts "#{users.size} users created."

unique_titles = Array.new(20000) { Faker::Lorem.sentence(word_count: 3) }
unique_bodies = Array.new(20000) { Faker::Lorem.paragraph }

posts = Array.new(posts_to_create) do
  {
    login: users.sample,
    title: unique_titles.sample,
    body: unique_bodies.sample,
    ip: ips.sample
  }  
end

batch_size = 500

Parallel.each(posts.in_groups_of(batch_size), in_threads: 20) do |batch|
  batch.each do |post|
    response = create_post(post[:login], post[:title], post[:body], post[:ip])
    if response.is_a?(Net::HTTPSuccess)
      created_posts += 1
    end
  end

  puts "#{created_posts}/#{posts_to_create} posts created" if created_posts % (10 * batch_size) == 0
end

puts "#{Post.count} posts created successfully via API!"

puts 'Creating Ratings'

total_posts = Post.count
ratings_to_create = (total_posts * 0.75).to_i
posts_to_rate = Post.order("RANDOM()").limit(ratings_to_create)
created_ratings = 0

Parallel.each(posts_to_rate.in_groups_of(batch_size), in_threads: 20) do |post|
  user_id = User.pluck(:id).sample
  create_rating(post.id, user_id)
  
  if response.is_a?(Net::HTTPSuccess)
    created_ratings += 1
  end
  
  puts "#{created_ratings}/#{posts_to_rate} ratings created" if created_ratings % (10 * batch_size) == 0
end

puts "#{User.count} users, #{Post.count} posts, #{Rating.count} ratings have been created successfully via API!"
