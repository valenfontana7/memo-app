class PostsController < ApplicationController 
  include Secured
  before_action :authenticate_user!, only: [:update, :create, :addowner, :delowner, :published_tasks, :published_task, :draft_tasks,:published_links, :published_link, :draft_links, :published_articles, :published_article, :draft_articles, :published_notes, :published_note, :draft_notes]
  rescue_from Exception do |e|
    render json: { error: e.message }, status: :internal_server_error
  end
  rescue_from ActiveRecord::RecordInvalid do |e|
    render json: { error: e.message }, status: :unprocessable_entity
  end
  rescue_from ActiveRecord::RecordNotFound do |e|
    render json: { error: e.message }, status: :not_found
  end

  # TASKS

  # GET /tasks
  def published_tasks
    @posts = Post.where(status: "published", core: "task")
    if params[:search].nil? || params[:search].present?
      @posts = PostsSearchService.search(@posts, params[:search])
    end
    render json: @posts.select {|post| post.users.ids.include?(Current.user.id)}, status: :ok
  end
  # GET /tasks/{id}
  def published_task
    @post = Post.find(params[:id])
    if ((@post.core == "task") && (Current.user && @post.users.ids.include?(Current.user.id))) || ((@post.core == "task") && (@post.visibility == "public" && @post.status == "published"))
      render json: @post, status: :ok
    else
      render json: { error: "404 Not Found"}, status: :not_found
    end
  end
  # GET /tasks/drafts
  def draft_tasks
    @posts = Post.where(status: "pending", core: "task")
    if params[:search].nil? || params[:search].present?
      @posts = PostsSearchService.search(@posts, params[:search])
    end
    render json: @posts.select {|post| post.users.ids.include?(Current.user.id)}, status: :ok
  end
  # GET /public/tasks  
  def published_public_tasks  
    @posts = Post.where(status: "published", core: "task", visibility: "public").includes(:user)  
    if !params[:search].nil? && params[:search].present?  
      @posts = PostsSearchService.search(@posts, params[:search])  
    end  
    render json: @posts, status: :ok  
  end 

    # LINKS

    # GET /links
    def published_links
      @posts = Post.where(status: "published", core: "link")
      if params[:search].nil? || params[:search].present?
        @posts = PostsSearchService.search(@posts, params[:search])
      end
      render json: @posts.select {|post| post.users.ids.include?(Current.user.id)}, status: :ok
    end
    # GET /links/{id}
    def published_link
      @post = Post.find(params[:id])
      if ((@post.core == "link") && (Current.user && @post.users.ids.include?(Current.user.id))) || ((@post.core == "link") && (@post.visibility == "public" && @post.status == "published"))
        render json: @post, status: :ok
      else
        render json: { error: "404 Not Found"}, status: :not_found
      end
    end
    # GET /links/drafts
    def draft_links
      @posts = Post.where(status: "pending", core: "link")
      if params[:search].nil? || params[:search].present?
        @posts = PostsSearchService.search(@posts, params[:search])
      end
      render json: @posts.select {|post| post.users.ids.include?(Current.user.id)}, status: :ok
    end
    # GET /public/links  
    def published_public_links 
      @posts = Post.where(status: "published", core: "link", visibility: "public").includes(:user)  
      if !params[:search].nil? && params[:search].present?  
        @posts = PostsSearchService.search(@posts, params[:search])  
      end  
      render json: @posts, status: :ok  
    end 

    # ARTICLES

    # GET /articles
    def published_articles
      @posts = Post.where(status: "published", core: "article")
      if params[:search].nil? || params[:search].present?
        @posts = PostsSearchService.search(@posts, params[:search])
      end
      render json: @posts.select {|post| post.users.ids.include?(Current.user.id)}, status: :ok
    end
    # GET /articles/{id}
    def published_article
      @post = Post.find(params[:id])
      if ((@post.core == "article") && (Current.user && @post.users.ids.include?(Current.user.id))) || ((@post.core == "article") && (@post.visibility == "public" && @post.status == "published"))
        render json: @post, status: :ok
      else
        render json: { error: "404 Not Found"}, status: :not_found
      end
    end
    # GET /articles/drafts
    def draft_articles
      @posts = Post.where(status: "pending", core: "article")
      if params[:search].nil? || params[:search].present?
        @posts = PostsSearchService.search(@posts, params[:search])
      end
      render json: @posts.select {|post| post.users.ids.include?(Current.user.id)}, status: :ok
    end
    # GET /public/articles  
    def published_public_articles 
      @posts = Post.where(status: "published", core: "article", visibility: "public").includes(:user)  
      if !params[:search].nil? && params[:search].present?  
        @posts = PostsSearchService.search(@posts, params[:search])  
      end  
      render json: @posts, status: :ok  
    end 

        # NOTES

    # GET /notes
    def published_notes
      @posts = Post.where(status: "published", core: "note")
      if params[:search].nil? || params[:search].present?
        @posts = PostsSearchService.search(@posts, params[:search])
      end
      render json: @posts.select {|post| post.users.ids.include?(Current.user.id)}, status: :ok
    end
    # GET /notes/{id}
    def published_note
      @post = Post.find(params[:id])
      if ((@post.core == "note") && (Current.user && @post.users.ids.include?(Current.user.id))) || ((@post.core == "note") && (@post.visibility == "public" && @post.status == "published"))
        render json: @post, status: :ok
      else
        render json: { error: "404 Not Found"}, status: :not_found
      end
    end
    # GET /notes/drafts
    def draft_notes
      @posts = Post.where(status: "pending", core: "note")
      if params[:search].nil? || params[:search].present?
        @posts = PostsSearchService.search(@posts, params[:search])
      end
      render json: @posts.select {|post| post.users.ids.include?(Current.user.id)}, status: :ok
    end
    # GET /public/notes  
    def published_public_notes 
      @posts = Post.where(status: "published", core: "note", visibility: "public").includes(:user)  
      if !params[:search].nil? && params[:search].present?  
        @posts = PostsSearchService.search(@posts, params[:search])  
      end  
      render json: @posts, status: :ok  
    end
  
    # POSTS in general

  # POST /posts
  def create
    if (create_params["visibility"] == "public" || create_params["visibility"] == "private") && (create_params["status"] == "pending" || create_params["status"] == "published") && (create_params["core"] == "link" || create_params["core"] == "note" || create_params["core"] == "task" || create_params["core"] == "article")
      @post = Post.new(create_params)
      Current.user.posts.append(@post)
      @post.users.append(Current.user)
      @post.save!
      render json: @post, status: :created
    else
      raise ActiveRecord::RecordInvalid
    end
  end
  # PUT /posts/{id}
  def update
    @post = Current.user.posts.find(params[:id])
    if (update_params["visibility"] == "public" || update_params["visibility"] == "private") && (update_params["status"] == "pending" || update_params["status"] == "published") && (update_params["core"] == "link" || update_params["core"] == "note" || update_params["core"] == "task" || update_params["core"] == "article")
      @post.update!(update_params) 
      render json: @post, status: :ok
    else
      raise ActiveRecord::RecordInvalid
    end
  end
  # PUT /posts/{id}/addowner/{uid}
  def addowner
    @user = User.find(params[:uid])
    @post = Current.user.posts.find(params[:id])
    if !@post
      render json: {"error": "Unauthorized"}, status: :unauthorized
    elsif !@user.posts.include?(@post)
      @user.posts.append(@post)
      @user.save!
      render json: @post, status: :ok
    else
      render json: {"error": "Post already belongs to that User"}, status: :unauthorized
    end
  end
  # PUT /posts/{id}/delowner/{uid}
  def delowner
    @user = User.find(params[:uid])
    @post = Current.user.posts.find(params[:id])
    if @user.posts.include?(@post)
      @post.users.delete(@user.id)
      render json: @post, status: :ok
    else
      render json: {"error": "Unauthorized"}, status: :unauthorized
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