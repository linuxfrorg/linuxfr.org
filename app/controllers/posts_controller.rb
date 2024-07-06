# encoding: UTF-8
class PostsController < ApplicationController
  before_action :authenticate_account!, except: [:index, :show]
  before_action :find_post,  except: [:new, :create, :index]
  after_action  :marked_as_read, only: [:show], if: :account_signed_in?
  after_action  :expire_cache, only: [:create, :update, :destroy]
  respond_to :html, :md

### Global ###

  def new
    @post = Post.new
    @post.forum_id = params[:forum_id]
    enforce_create_permission(@post)
  end

  def create
    @post = Post.new
    enforce_create_permission(@post)
    @post.attributes = post_params
    @post.tmp_owner_id = current_account.user_id
    if !preview_mode && @post.save
      current_account.tag(@post.node, params[:tags])
      redirect_to forum_posts_url(forum_id: @post.forum), notice: "Votre message a bien été créé"
    else
      @post.node = Node.new
      @post.node.preview_tags = params[:tags]
      @post.valid?
      render :new
    end
  end

### By forum ###

  def index
    @forum = Forum.find(params[:forum_id])
    redirect_to @forum, status: 301
  end

  def show
    enforce_view_permission(@post)
    path = forum_post_path(@forum, @post, format: params[:format])
    redirect_to path, status: 301 and return if request.path != path
    headers['Link'] = %(<#{forum_post_url @forum, @post}>; rel="canonical")
    flash.now[:alert] = "Attention, ce message a été supprimé et n’est visible que par l’équipe d'administration" unless @post.visible?
  end

  def edit
    enforce_update_permission(@post)
  end

  def update
    @post.attributes = post_params
    enforce_update_permission(@post)
    if !preview_mode && @post.save
      redirect_to forum_posts_url, notice: "Votre message a bien été modifié"
    else
      flash.now[:alert] = "Impossible d’enregistrer ce message" if @post.invalid?
      render :edit
    end
  end

  def destroy
    enforce_destroy_permission(@post)
    @post.mark_as_deleted
    Board.amr_notification("Le message #{forum_post_url @forum, @post} a été supprimé par #{current_user.name} #{user_url(current_user)}")
    redirect_to forum_posts_url, notice: "Votre message a bien été supprimé"
  end

protected

  def post_params
    params.require(:post).permit(:title, :wiki_body, :forum_id, :cc_licensed)
  end

  def find_post
    @forum = Forum.find(params[:forum_id])
    @post  = @forum.posts.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    post = Post.find(params[:id])
    redirect_to [post.forum, post]
  end

  def marked_as_read
    current_account.read(@post.node) unless params[:format] == "md"
  end

  def expire_cache
    return if @post.new_record?
    expire_page controller: "forums", action: :index, format: :atom
    expire_page controller: "forums", action: :show, id: @post.forum.to_param, format: :atom
  end
end
