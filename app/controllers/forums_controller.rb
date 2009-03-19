class ForumsController < ApplicationController
  before_filter :find_forums

  def index
    @posts = Post.sorted.paginate :page => params[:page], :per_page => 10
    respond_to do |wants|
      wants.html
      wants.atom
    end
  end

  def show
    @forum = Forum.find(params[:id])
    @posts = @forum.posts.sorted.paginate(:page => params[:page], :per_page => 10)
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
