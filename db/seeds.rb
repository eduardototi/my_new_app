require 'net/http'

def create_post(user:, title:, body:)
  uri = URI("http://localhost:3000/api/v1/posts")
  http = Net::HTTP.new(uri.host, uri.port)

  request = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json' })
  request.body = {
    user: {
      login: user[:login],
      ip: user[:ip]
    },
    title: title,
    body: body
  }.to_json

  http.request(request)
end

def create_rating(post_id:, user_id:)
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
users = Array.new(100) { { login: Faker::Internet.unique.username, ip: ips.sample } }
posts_to_create = 200_000
created_posts = 0

users.each do |user|
  response = create_post(user: user, title: Faker::Lorem.sentence(word_count: 3), body: Faker::Lorem.paragraph)
  created_posts += 1 if response.is_a?(Net::HTTPSuccess)
end

puts "Created initial posts for each user. Total: #{created_posts} posts."

remaining_posts = posts_to_create - created_posts
unique_titles = Array.new(2000) { Faker::Lorem.sentence(word_count: 3) }
unique_bodies = Array.new(2000) { Faker::Lorem.paragraph }

posts = Array.new(remaining_posts) do
  {
    user: users.sample,
    title: unique_titles.sample,
    body: unique_bodies.sample
  }
end

batch_size = 500

Parallel.each(posts.in_groups_of(batch_size, false), in_threads: 30) do |batch|
  batch.each do |post|
    break if created_posts >= posts_to_create

    response = create_post(user: post[:user], title: post[:title], body: post[:body])
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
    response = create_rating(post_id: post.id, user_id: user_id)
    created_ratings += 1 if response.is_a?(Net::HTTPSuccess)
  end

  puts "#{created_ratings}/#{ratings_to_create} ratings created at #{Time.zone.now}" if created_ratings % (10 * batch_size) == 0
end

puts "#{User.count} users, #{Post.count} posts, #{Rating.count} ratings have been created at #{Time.zone.now} successfully via API!"
