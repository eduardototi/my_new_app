require 'rails_helper'

RSpec.describe Post, type: :model do
  let(:post) { create(:post) }

  describe 'associations' do
    it { should have_many(:ratings).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:body) }
    it { should validate_presence_of(:ip) }
  end

  describe '.top_rated' do
    let!(:user) { create(:user) }
    let!(:post1) { create(:post) }
    let!(:post2) { create(:post) }
    let!(:rating1) { create(:rating, post: post1, value: 5) }
    let!(:rating2) { create(:rating, post: post1, value: 4) }
    let!(:rating3) { create(:rating, post: post2, value: 3) }

    it 'returns posts ordered by average rating' do
      expect(Post.top_rated).to eq([ post1, post2 ])
    end

    it 'limits the number of posts returned' do
      expect(Post.top_rated(1).to_a.count).to eq(1)
    end
  end

  describe '#average_rating' do
    let!(:rating1) { create(:rating, post: post, value: 5) }
    let!(:rating2) { create(:rating, post: post, value: 3) }

    it 'returns the average rating of the post' do
      expect(post.average_rating).to eq(4)
    end

    it 'returns 0 if there are no ratings' do
      post = create(:post)
      expect(post.average_rating).to eq(0)
    end
  end
end
