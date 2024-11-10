class Api::V1::PostsController < ApplicationController
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid

  def create
    with_transaction do
      find_or_create_user
      create_post
      @post.save!
      render_json_response(@post, :created)
    end
  end

  def top_rated_posts
    n = params[:n].present? ? params[:n].to_i : 10
    posts = Post.top_rated(n)

    if posts.any?
      render_json_response(posts, :ok)
    else
      render_json_error("No posts found", :not_found)
    end
  end

  def ips_list
    ips_with_authors = ips_with_authors_query

    render json: ips_with_authors.as_json(except: [ :id ]), status: :ok
  end

  private

  def ips_with_authors_query
    Post.joins(:user)
      .select("posts.ip, array_agg(DISTINCT users.login) AS author_logins")
      .group("posts.ip")
      .having("COUNT(posts.id) > 1")
      .order("posts.ip")
  end

  def create_post
    @post = @user.posts.build(post_params)
  end

  def find_or_create_user
    @user = User.find_or_create_by(login: user_params[:login])
  end

  def post_params
    params.require(:post).permit(:title, :body, :ip)
  end

  def user_params
    params.require(:post).permit(:login)
  end

  def record_invalid(e)
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
  end

  def render_json_response(resource, status)
    render json: { posts: resource }, status: status
  end

  def render_json_error(resource, status)
    render json: { errors: resource }, status: status
  end
end
