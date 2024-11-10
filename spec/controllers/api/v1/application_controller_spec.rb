require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  describe '#with_transaction' do
    it 'executes the block within a transaction' do
      expect(ActiveRecord::Base).to receive(:transaction).and_yield

      block_executed = false

      controller.with_transaction do
        block_executed = true
      end

      expect(block_executed).to be true
    end
  end
end
