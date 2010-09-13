class UsersController < ApplicationController
  before_filter :find_user

  def show
    find_nodes(Diary)
    respond_to do |wants|
      wants.html
      wants.atom { render 'diaries/index' }
    end
  end

  def news
    find_nodes(News)
    respond_to do |wants|
      wants.html
      wants.atom { render 'news/index' }
    end
  end

  def posts
    find_nodes(Post)
    respond_to do |wants|
      wants.html
      wants.atom { render 'forums/index' }
    end
  end

  def suivi
    find_nodes(Tracker)
  end

  def comments
    @comments = @user.comments.published.order('created_at DESC').paginate(:page => params[:page], :per_page => 20)
    respond_to do |wants|
      wants.html
      wants.atom { render 'comments/index' }
    end
  end

protected

  def find_user
    @user = User.find(params[:id])
    raise ActiveRecord::RecordNotFound.new unless @user
    @contents = @user.nodes.by_date.limit(20)
  end

  def find_nodes(klass)
    @order = params[:order] || 'created_at'
    @nodes = Node.public_listing(klass, @order).where("nodes.user_id" => @user.id).paginate(:page => params[:page], :per_page => 10)
  end

end
