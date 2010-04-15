class PostsController < ApplicationController
  before_filter :authenticate_account!, :except => [:index, :show]
  before_filter :find_forum, :except => [:new, :create]
  before_filter :find_post,  :except => [:new, :create, :index]
  after_filter  :marked_as_read, :only => [:show]

### Global ###

  def new
    @post = Post.new
    enforce_view_permission(@post)
  end

  def create
    @post = Post.new
    @post.attributes = params[:post]
    enforce_create_permission(@post)
    if !preview_mode && @post.save
      @post.create_node(:user_id => current_user.id)
      redirect_to forum_posts_url(:forum_id => @post.forum_id), :notice => "Votre message a bien été créé"
    else
      @post.node = Node.new
      render :new
    end
  end

### By forum ###

  def index
    redirect_to @forum
  end

  def show
    enforce_view_permission(@post)
    redirect_to @post, :status => 301 if !@post.friendly_id_status.best?
  end

  def edit
    enforce_update_permission(@post)
  end

  def update
    @post.attributes = params[:post]
    enforce_update_permission(@post)
    if !preview_mode && @post.save
      redirect_to forum_posts_url, :notice => "Votre message a bien été modifié"
    else
      flash.now[:alert] = "Impossible d'enregistrer ce message"
      render :edit
    end
  end

  def destroy
    enforce_destroy_permission(@post)
    @post.mark_as_deleted
    redirect_to forum_posts_url, :notice => "Votre message a bien été supprimé"
  end

protected

  def find_forum
    @forum = Forum.find(params[:forum_id])
  end

  def find_post
    @post = @forum.posts.find(params[:id])
  end

  def marked_as_read
    current_user.read(@post.node) if current_user
  end

end
