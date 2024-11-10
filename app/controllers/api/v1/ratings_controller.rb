class Api::V1::RatingsController < ApplicationController
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid

  def create
    with_transaction do
      @rating = Rating.create!(rating_params)
      render json: { post_id: @rating.post_id, average_rating: @rating.post.average_rating }, status: :created
    end
  end

  private

  def record_invalid(e)
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
  end

  def rating_params
    params.require(:rating).permit(:post_id, :user_id, :value)
  end
end
