class ForumsController < ApplicationController

  def index
    @forums = Forum.sorted.all
    #@posts = Post.paginate :page => params[:page], :per_page => 10
  end

  def show
    @forum = Forum.find(params[:id])
  end

end
