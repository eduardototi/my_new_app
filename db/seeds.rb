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
    login: login,
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

  100.times do |i|
    login = Faker::Internet.unique.username
    title = Faker::Lorem.sentence(word_count: 3)
    body = Faker::Lorem.paragraph
    ip = ips.sample

    create_post(login, title, body, ip)
  end

puts "#{User.count} users created"
  users = User.pluck(:login)
  total_posts = 199_900
  max_threads = [100, total_posts / 10].min

  posts = Array.new(total_posts) do
    {
      login: users.sample,
      title: Faker::Lorem.sentence(word_count: 3),
      body: Faker::Lorem.paragraph,
      ip: ips.sample
    }
  end

  Parallel.each(posts, in_threads: 10) do |post|
    create_post(post[:login], post[:title], post[:body], post[:ip])
  end

puts "#{Post.count} posts created"

puts 'Creating Rartings'
  total_posts = Post.count
  ratings_to_create = (total_posts * 0.75).to_i
  posts_to_rate = Post.order("RANDOM()").limit(ratings_to_create)

  Parallel.each(posts_to_rate, in_threads: 10) do |post|
    user_id = User.pluck(:id).sample
    create_rating(post.id, user_id)
  end
  
puts "#{User.count} users, #{Post.count} posts, #{Rating.count} rating have been created successfully via API!"


