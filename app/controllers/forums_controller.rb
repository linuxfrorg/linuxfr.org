class ForumsController < ApplicationController
  before_filter :find_forums
  before_filter :get_order

  def index
    @posts = Post.published.joins(:node).order(@order).paginate(:page => params[:page], :per_page => 10)
    respond_to do |wants|
      wants.html
      wants.atom
    end
  end

  def show
    @forum = Forum.find(params[:id])
    @posts = @forum.posts.published.joins(:node).order(@order).paginate(:page => params[:page], :per_page => 10)
    respond_to do |wants|
      wants.html
      wants.atom
    end
  end

protected

  def find_forums
    @forums = Forum.sorted
  end

  def get_order
    @order = "nodes." + (params[:order] || "created_at") + " DESC"
  end

end
