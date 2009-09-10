class PostsController < ApplicationController
  before_filter :user_required, :except => [:index, :show]
  before_filter :find_forum, :except => [:new, :create]
  after_filter  :marked_as_read, :only => [:show]

### Global ###

  def new
    @preview_mode = false
    @post = Post.new
    raise ActiveRecord::RecordNotFound.new unless @post && @post.creatable_by?(current_user)
  end

  def create
    @post = Post.new
    @post.attributes = params[:post]
    raise ActiveRecord::RecordNotFound.new unless @post && @post.creatable_by?(current_user)
    @preview_mode = (params[:commit] == 'Prévisualiser')
    if !@preview_mode && @post.save
      @post.create_node(:user_id => current_user.id)
      flash[:success] = "Votre message a bien été créé"
      redirect_to forum_posts_url(:forum_id => @post.forum_id)
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
    @post = @forum.posts.find(params[:id])
    raise ActiveRecord::RecordNotFound.new unless @post && @post.readable_by?(current_user)
  end

  def edit
    @post = @forum.posts.find(params[:id])
    raise ActiveRecord::RecordNotFound.new unless @post && @post.editable_by?(current_user)
  end

  def update
    @post = @forum.posts.find(params[:id])
    @post.attributes = params[:post]
    raise ActiveRecord::RecordNotFound.new unless @post && @post.editable_by?(current_user)
    @preview_mode = (params[:commit] == 'Prévisualiser')
    if !@preview_mode && @post.save
      flash[:success] = "Votre message a bien été modifié"
      redirect_to forum_posts_url
    else
      render :edit
    end
  end

  def destroy
    @post = @forum.posts.find(params[:id])
    raise ActiveRecord::RecordNotFound.new unless @post && @post.deletable_by?(current_user)
    @post.mark_as_deleted
    flash[:success] = "Votre message a bien été supprimé"
    redirect_to forum_posts_url
  end

protected

  def find_forum
    @forum = Forum.find(params[:forum_id])
  end

  def marked_as_read
    current_user.read(@post.node) if current_user
  end

end
