require 'rails_helper'

RSpec.describe Api::V1::PostsController, type: :controller do
  describe 'POST #create' do
    let(:valid_attributes) do
      {
        post: { title: 'Title', body: 'Body' },
        user: { login: 'john_doe', ip: '123.234.345' }
      }
    end

    let(:invalid_attributes) do
      {
        post: { title: 'Title', body: 'Body' },
        user: { login: nil, ip: '123.234.345' }
      }
    end

    context 'with valid attributes and user does not exists' do
      it 'creates a new user and post' do
        expect {
          post :create, params: valid_attributes
        }.to change(Post, :count).by(1)

        expect(response).to have_http_status(:created)
        json_response = response.parsed_body
        expect(json_response[:user][:login]).to eq('john_doe')
      end
    end

    context 'with valid attributes and user does exists' do
      let!(:user) { create(:user, login: 'john_doe') }

      it 'does not creates a new user and creates a new post' do
        expect {
          post :create, params: valid_attributes
        }.not_to change(User, :count) and change(Post, :count).by(1)

        expect(response).to have_http_status(:created)
        json_response = response.parsed_body
        expect(json_response[:user][:login]).to eq('john_doe')
      end
    end

    context 'with invalid attributes' do
      it 'does not create a new post without user login present' do
        expect {
          post :create, params: invalid_attributes
        }.not_to change(Post, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = response.parsed_body
        expect(json_response['errors']).to include("User can't be blank")
      end
    end

    context 'when params are missing' do
      let(:missing_attributes) do
        {
          post: { title: 'Title', body: 'Body' }
        }
      end

      it 'returns bad request' do
        post :create, params: missing_attributes

        expect(response).to have_http_status(:bad_request)
        json_response = response.parsed_body
        expect(json_response['error']).to eq('param is missing or the value is empty: user')
      end
    end
  end

  describe 'GET #ips_list' do
    context 'with top rated posts' do
      let!(:user)   { create(:user, login: 'john_doe_2') }
      let!(:post_1) { create(:post, user: user, ip: '123.456.789') }
      let!(:post_2) { create(:post, ip: '123.456.789') }

      it 'returns top rated posts' do
        get :ips_list

        expect(response).to have_http_status(:ok)
        json_response = response.parsed_body
        expect(json_response.size).to eq(1)
        expect(json_response.first["author_logins"]).to be_an(Array)
        expect(json_response.first["author_logins"]).to include("john_doe_2")
      end
    end
  end

  describe 'GET #top_rated' do
    context 'with top rated posts' do
      let!(:user)   { create(:user, login: 'john_doe_2') }
      let!(:post_1) { create(:post, user: user) }
      let!(:post_2) { create(:post) }
      let!(:rating_1) { create(:rating, post: post_1, value: 5) }
      let!(:rating_2) { create(:rating, post: post_2, value: 1) }

      it 'returns top rated posts' do
        get :top_rated, params: { n: 2 }

        expect(response).to have_http_status(:ok)
        json_response = response.parsed_body
        first_post = json_response["posts"].first

        expect(json_response.size).to eq(1)
      end
    end

    context 'without top rated posts' do
      it 'returns no posts found' do
        get :top_rated, params: { n: 2 }

        expect(response).to have_http_status(:not_found)
        json_response = response.parsed_body
        expect(json_response["errors"]).to eq("No posts found")
      end
    end
  end

  describe "#render_json_response" do
    let(:post) { create(:post) }
    let(:status) { :ok }

    it "renders the correct JSON response" do
      allow(controller).to receive(:render)

      controller.send(:render_json_response, post, status)
      expect(controller).to have_received(:render).with(
        json: { posts: post, user: post.user },  # Esperando o post e seu user
        status: status
      )
    end
  end
end
