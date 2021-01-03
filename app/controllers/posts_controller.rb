class PostsController < ApplicationController 
  include Secured
  before_action :authenticate_user!, only: [:update, :create, :published_tasks, :published_task, :draft_tasks, :draft_task]
  rescue_from Exception do |e|
    render json: { error: e.message }, status: :internal_server_error
  end
  rescue_from ActiveRecord::RecordInvalid do |e|
    render json: { error: e.message }, status: :unprocessable_entity
  end
  rescue_from ActiveRecord::RecordNotFound do |e|
    render json: { error: e.message }, status: :not_found
  end
  # GET /tasks
  def published_tasks
    @posts = Post.where(status: "published", core: "task", user_id: Current.user.id)
    if params[:search].nil? || params[:search].present?
      @posts = PostsSearchService.search(@posts, params[:search])
    end
    render json: @posts, status: :ok
  end
  # GET /tasks/drafts
  def draft_tasks
    @posts = Post.where(status: "pending", core: "task", user_id: Current.user.id)
    if params[:search].nil? || params[:search].present?
      @posts = PostsSearchService.search(@posts, params[:search])
    end
    render json: @posts, status: :ok
  end
  # GET /tasks/drafts/{id}
  def draft_task
    @post = Post.find(params[:id])
    if Current.user && @post.user_id == Current.user.id
      render json: @post, status: :ok
    else
      render json: { error: "404 Not Found"}, status: :not_found
    end
  end
  # GET /public/tasks  
  def published_public_tasks  
    @posts = Post.where(status: "published", core: "task", visibility: "public").includes(:user)  
    if !params[:search].nil? && params[:search].present?  
      @posts = PostsSearchService.search(@posts, params[:search])  
    end  
    render json: @posts, status: :ok  
  end 
  # GET /public/tasks/{id}  
  def published_public_task  
    @post = Post.includes(:user).find(params[:id])
    if @post.status == "published"
      render json: @post, status: :ok
    else
      render json: { error: "404 Not Found"}, status: :not_found
    end
  end 
  # GET /tasks/{id}
  def published_task
    @post = Post.find(params[:id])
    if Current.user && @post.user_id == Current.user.id
      render json: @post, status: :ok
    else
      render json: { error: "404 Not Found"}, status: :not_found
    end
  end
  # POST /posts
  def create
    if create_params["visibility"] == "public" || create_params["visibility"] == "private" && create_params["status"] == "pending" || create_params["status"] == "published" && create_params["core"] == "link" || create_params["core"] == "note" || create_params["core"] == "task" || create_params["core"] == "article"
      @post = Current.user.posts.create!(create_params) 
      render json: @post, status: :created
    else
      raise ActiveRecord::RecordInvalid
    end
  end
  # PUT /posts/{id}
  def update
    @post = Current.user.posts.find(params[:id])
    if update_params["visibility"] == "public" || update_params["visibility"] == "private" && update_params["status"] == "pending" || update_params["status"] == "published" && update_params["core"] == "link" || update_params["core"] == "note" || update_params["core"] == "task" || update_params["core"] == "article"
      @post.update!(update_params) 
      render json: @post, status: :ok
    else
      raise ActiveRecord::RecordInvalid
    end
  end

  private

  def create_params
    params.require(:post).permit(:title, :content, :link, :status, :core, :visibility)
  end
  def update_params
    params.require(:post).permit(:title, :content, :link, :status, :core, :visibility)
  end
  
end