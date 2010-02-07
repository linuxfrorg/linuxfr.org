class ForumsController < ApplicationController
  before_filter :find_forums

  def index
    @order = params[:order] || 'created_at'
    @posts = Post.published.joins(:nodes).order("nodes.#{@order} DESC").paginate(:page => params[:page], :per_page => 10)
    respond_to do |wants|
      wants.html
      wants.atom
    end
  end

  def show
    @order = params[:order] || 'created_at'
    @forum = Forum.find(params[:id])
    @posts = @forum.posts.published.joins(:nodes).order("nodes.#{@order} DESC").paginate(:page => params[:page], :per_page => 10)
    respond_to do |wants|
      wants.html
      wants.atom
    end
  end

protected

  def find_forums
    @forums = Forum.sorted
  end

end
