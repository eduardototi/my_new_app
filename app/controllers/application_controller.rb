class ApplicationController < ActionController::API
  rescue_from ActionDispatch::Http::Parameters::ParseError, with: :handle_parse_error
  rescue_from ActionController::ParameterMissing, with: :params_missing

  def with_transaction
    ActiveRecord::Base.transaction do
      yield
    end
  end

  private

  def handle_parse_error(exception)
    render json: { error: "Invalid JSON format" }, status: :bad_request
  end

  def params_missing(exception)
    render json: { error: exception.message }, status: :bad_request
  end
end
