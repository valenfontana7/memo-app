class PostsController < ApplicationController 
  rescue_from Exception do |e|
    render json: { error: e.message }, status: :internal_server_error
  end
  rescue_from ActiveRecord::RecordInvalid do |e|
    render json: { error: "Los parámetros ingresados no son válidos" }, status: :unprocessable_entity
  end
  # GET /tasks
  def published_tasks
    @posts = Post.where(status: "published").includes(:user)
    if !params[:search].nil? && params[:search].present?
      @posts = PostsSearchService.search(@posts, params[:search])
    end
    render json: @posts, status: :ok
  end
  # GET /public/tasks  
  def published_public_tasks  
    @posts = Post.where(status: "published", visibility: "public").includes(:user)  
    if !params[:search].nil? && params[:search].present?  
      @posts = PostsSearchService.search(@posts, params[:search])  
    end  
    render json: @posts, status: :ok  
  end 
  # GET /tasks/{id}
  def task
    @post = Post.find(params[:id])
    render json: @post, status: :ok
  end
  # POST /posts
  def create
    if create_params["visibility"] == "public" || create_params["visibility"] == "private" && create_params["status"] == "pending" || create_params["status"] == "published" && create_params["core"] == "link" || create_params["core"] == "note" || create_params["core"] == "task" || create_params["core"] == "article"
      @post = Post.create!(create_params) 
      render json: @post, status: :created
    else
      raise ActiveRecord::RecordInvalid
    end
  end
  # PUT /posts/{id}
  def update
    @post = Post.find(params[:id])
    if update_params["visibility"] == "public" || update_params["visibility"] == "private" && update_params["status"] == "pending" || update_params["status"] == "published" && update_params["core"] == "link" || update_params["core"] == "note" || update_params["core"] == "task" || update_params["core"] == "article"
      @post.update!(update_params) 
      render json: @post, status: :ok
    else
      raise ActiveRecord::RecordInvalid
    end
  end

  private

  def create_params
    params.require(:post).permit(:title, :content, :link, :status, :core, :visibility, :user_id)
  end
  def update_params
    params.require(:post).permit(:title, :content, :link, :status, :core, :visibility)
  end
end