# encoding: UTF-8
class PostsController < ApplicationController
  before_filter :authenticate_account!, :except => [:index, :show]
  before_filter :find_post,  :except => [:new, :create, :index]
  after_filter  :marked_as_read, :only => [:show], :if => :account_signed_in?
  after_filter  :expire_cache, :only => [:create, :update, :destroy]

### Global ###

  def new
    @post = Post.new
    @post.forum_id = params[:forum_id]
    enforce_create_permission(@post)
  end

  def create
    @post = Post.new
    enforce_create_permission(@post)
    @post.attributes = params[:post]
    @post.owner_id = current_account.user_id
    if !preview_mode && @post.save
      redirect_to forum_posts_url(:forum_id => @post.forum), :notice => "Votre message a bien été créé"
    else
      @post.node = Node.new
      @post.valid?
      render :new
    end
  end

### By forum ###

  def index
    @forum = Forum.find(params[:forum_id])
    redirect_to @forum, :status => 301
  end

  def show
    enforce_view_permission(@post)
    redirect_to [@forum, @post], :status => 301 if !@post.friendly_id_status.best?
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
      flash.now[:alert] = "Impossible d'enregistrer ce message" if @post.invalid?
      render :edit
    end
  end

  def destroy
    enforce_destroy_permission(@post)
    @post.mark_as_deleted
    redirect_to forum_posts_url, :notice => "Votre message a bien été supprimé"
  end

protected

  def find_post
    @forum = Forum.find(params[:forum_id])
    @post  = @forum.posts.find(params[:id])
    redirect_to [@forum, @post], :status => 301 if !@forum.friendly_id_status.best? || !@post.friendly_id_status.best?
  end

  def marked_as_read
    current_account.read(@post.node)
  end

  def expire_cache
    return if @post.new_record?
    expire_page :controller => "forums", :action => :index, :format => :atom
    expire_page :controller => "forums", :action => :show, :id => @post.forum.to_param, :format => :atom
  end
end
