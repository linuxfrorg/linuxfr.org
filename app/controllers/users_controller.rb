class UsersController < ApplicationController
  before_filter :find_user

  def show
    redirect_to @user, :status => 301 and return if !@user.friendly_id_status.best?
    find_nodes(Diary)
    respond_to do |wants|
      wants.html
      wants.atom { render 'diaries/index' }
    end
  end

  def news
    redirect_to news_user_path(@user), :status => 301 and return if !@user.friendly_id_status.best?
    find_nodes(News)
    respond_to do |wants|
      wants.html
      wants.atom { render 'news/index' }
    end
  end

  def posts
    redirect_to posts_user_path(@user), :status => 301 and return if !@user.friendly_id_status.best?
    find_nodes(Post)
    respond_to do |wants|
      wants.html
      wants.atom { render 'forums/index' }
    end
  end

  def suivi
    redirect_to suivi_user_path(@user), :status => 301 and return if !@user.friendly_id_status.best?
    find_nodes(Tracker)
  end

  def comments
    redirect_to comments_user_path(@user), :status => 301 and return if !@user.friendly_id_status.best?
    @comments = @user.comments.published.order('created_at DESC').page(params[:page])
    respond_to do |wants|
      wants.html
      wants.atom { render 'comments/index' }
    end
  end

protected

  def find_user
    @user = User.find(params[:id])
    raise ActiveRecord::RecordNotFound.new unless @user
    @contents = @user.nodes.visible.by_date.limit(20)
  end

  def find_nodes(klass)
    @order = params[:order]
    @order = "created_at" unless VALID_ORDERS.include?(@order)
    @nodes = Node.public_listing(klass, @order).where("nodes.user_id" => @user.id).page(params[:page])
  end

end
