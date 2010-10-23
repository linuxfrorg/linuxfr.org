class ForumsController < ApplicationController
  before_filter :find_forums
  before_filter :get_order

  def index
    @nodes = Node.public_listing(Post, @order).paginate(:page => params[:page], :per_page => 10)
    respond_to do |wants|
      wants.html
      wants.atom
    end
  end

  def show
    @forum = Forum.find(params[:id])
    @posts = @forum.posts.with_node_ordered_by(@order).paginate(:page => params[:page], :per_page => 10)
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
    @order = params[:order]
    @order = "created_at" unless VALID_ORDERS.include?(@order)
  end

end
