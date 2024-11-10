# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require 'net/http'
require 'json'

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
  created_users = 0

  while created_users < 100
    login = Faker::Internet.unique.username
    title = Faker::Lorem.sentence(word_count: 3)
    body = Faker::Lorem.paragraph
    ip = ips.sample
  
    response = create_post(login, title, body, ip)
  
    if response.is_a?(Net::HTTPSuccess)
      created_users += 1
      puts "Created #{created_users}/100 user and posts"
    end
  end

puts "#{User.count} users created"
  users = User.pluck(:login)
  total_posts = 900
  max_threads = [100, total_posts / 10].min

  posts = Array.new(total_posts) do
    {
      login: users.sample,
      title: Faker::Lorem.sentence(word_count: 3),
      body: Faker::Lorem.paragraph,
      ip: ips.sample
    }
  end

  created_posts = 100

  Parallel.each(posts, in_threads: 20) do |post|
    create_post(post[:login], post[:title], post[:body], post[:ip])

    created_posts += 1
  
    if created_posts % 100 == 0
      puts "#{created_posts} posts created"
    end
  end

puts "#{Post.count} posts created"

puts 'Creating Rartings'
  total_posts = Post.count
  ratings_to_create = (total_posts * 0.75).to_i
  posts_to_rate = Post.order("RANDOM()").limit(ratings_to_create)
  created_ratings = 0

  Parallel.each(posts_to_rate, in_threads: 20) do |post|
    user_id = User.pluck(:id).sample
    create_rating(post.id, user_id)

    created_ratings += 1
  
    if created_ratings % 100 == 0
      puts "#{created_ratings} ratings created"
    end
  end
  
puts "#{User.count} users, #{Post.count} posts, #{Rating.count} ratings have been created successfully via API!"