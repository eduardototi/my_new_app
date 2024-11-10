require 'rails_helper'

RSpec.describe Api::V1::RatingsController, type: :controller do
  describe 'POST #create' do
    let(:user) { create(:user) }
    let(:post_record) { create(:post) }

    let(:valid_attributes) do
      { post_id: post_record.id, user_id: user.id, value: 4 }
    end

    let(:invalid_attributes) do
      { post_id: post_record.id, user_id: nil, value: 4 }
    end

    context 'with valid attributes' do
      it 'creates a new rating and returns the average rating' do
        expect {
          post :create, params: { rating: valid_attributes }
        }.to change(Rating, :count).by(1)

        expect(response).to have_http_status(:created)
        json_response = response.parsed_body

        expect(json_response['post_id']).to eq(valid_attributes[:post_id])
        expect(json_response['average_rating']).to eq(post_record.reload.average_rating)
      end
    end

    context 'with valid attributes (user has already rated the post)' do
      it 'does not create a duplicate rating for the same user' do
        create(:rating, user: user, post: post_record, value: 4)

        expect {
          post :create, params: { rating: valid_attributes }
        }.not_to change(Rating, :count)

        json_response = response.parsed_body
        expect(json_response['errors']).to include("User has already rated this post.")
      end

      it 'ensures only one rating per user per post under simulated concurrent requests' do
        10.times do
          post :create, params: { rating: valid_attributes }
        end

        post_record.reload

        expect(post_record.ratings.where(user_id: user.id).count).to eq(1)

        expect(post_record.average_rating).to eq(4)
      end
    end

    context 'with invalid attributes' do
      it 'does not create a new rating' do
        expect {
          post :create, params: { rating: invalid_attributes }
        }.not_to change(Rating, :count)


        expect(response).to have_http_status(:unprocessable_entity)
        json_response = response.parsed_body
        expect(json_response['errors']).to include('User must exist')
      end
    end
  end
end
