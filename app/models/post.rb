class Post < ApplicationRecord
  belongs_to :user
  has_many :ratings, dependent: :destroy

  validates :user_id, :title, :body, :ip, presence: true

  scope :top_rated, ->(limit = 10) {
    joins(:ratings)
    .group("posts.id")
    .select("posts.id, posts.title, posts.body, AVG(ratings.value) AS average_rating")
    .order("average_rating DESC")
    .limit(limit)
  }

  def average_rating
    ratings.sum(:value) / ratings.count
  end
end
