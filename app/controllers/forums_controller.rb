class ForumsController < ApplicationController
  before_filter :find_forums
  before_filter :get_order
  caches_page   :index, :if => Proc.new { |c| c.request.format.atom? && !c.request.ssl? }
  caches_page   :show,  :if => Proc.new { |c| c.request.format.atom? && !c.request.ssl? }

  def index
    @nodes = Node.public_listing(Post, @order).page(params[:page])
    respond_to do |wants|
      wants.html
      wants.atom
    end
  end

  def show
    @forum = Forum.find(params[:id])
    redirect_to(@forum, :status => 301) and return if !@forum.friendly_id_status.best?
    @posts = @forum.posts.with_node_ordered_by(@order).page(params[:page])
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
