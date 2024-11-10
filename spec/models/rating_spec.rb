require 'rails_helper'

RSpec.describe Rating, type: :model do
  it { should belong_to(:user) }
  it { should belong_to(:post) }
  it { should validate_presence_of(:value) }
  it { should validate_inclusion_of(:value).in_range(1..5) }

  describe 'validations' do
    let!(:post) { create(:post) }
    let!(:user) { create(:user) }

    context 'when the user has already rated the post' do
      before do
        create(:rating, user: user, post: post)
      end

      it 'is invalid' do
        rating = Rating.new(user: user, post: post)
        expect(rating).to be_invalid
        expect(rating.errors[:user_id]).to include('has already rated this post.')
      end
    end

    context 'when the user has not rated the post yet' do
      it 'is valid' do
        rating = Rating.create!(user: user, post: post, value: 5)
        expect(rating).to be_valid
      end
    end
  end
end
