class ApplicationController < ActionController::API
  def with_transaction
    ActiveRecord::Base.transaction do
      yield
    end
  end
end
