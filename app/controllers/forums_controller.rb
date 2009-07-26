class ForumsController < ApplicationController
  before_filter :find_forums

  def index
    @order = params[:order] || 'created_at'
    @posts = Post.paginate(:page => params[:page], :per_page => 10, :order => "nodes.#{@order} DESC", :joins => :node)
    respond_to do |wants|
      wants.html
      wants.atom
    end
  end

  def show
    @order = params[:order] || 'created_at'
    @forum = Forum.find(params[:id])
    @posts = @forum.posts.paginate(:page => params[:page], :per_page => 10, :order => "nodes.#{@order} DESC", :joins => :node)
    respond_to do |wants|
      wants.html
      wants.atom
    end
  end

protected

  def find_forums
    @forums = Forum.sorted.all
  end

end
