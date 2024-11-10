class Post < ApplicationRecord
  belongs_to :user
  has_many :ratings, dependent: :destroy

  validates :user_id, :title, :body, :ip, presence: true

  scope :top_rated, ->(limit = 10) {
    joins(:ratings)
    .group("posts.id")
    .select("posts.id, posts.title, posts.body")
    .order("AVG(ratings.value) DESC")
    .limit(limit)
  }
  

  scope :ip_with_multiple_posts, -> {
    joins(:user)
    .select("posts.ip, array_agg(DISTINCT users.login) AS author_logins")
    .group("posts.ip")
    .having("COUNT(posts.id) > 1")
    .order("posts.ip")
  }

  def average_rating
    ratings.sum(:value) / ratings.count
  end
end
