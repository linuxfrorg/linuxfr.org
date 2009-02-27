class Admin::ForumsController < AdminController

  def index
    @forums = Forum.sorted.all
    #@posts = Post.paginate :page => params[:page], :per_page => 10
  end

  def new
    @forum = Forum.new
  end

  def create
    @forum = Forum.new
    @forum.attributes = params[:forum]
    if @forum.save
      @forum.move_to_bottom
      flash[:success] = "Forum créé"
      redirect_to admin_forums_url
    else
      render :new
    end
  end

  def edit
    @forum = Forum.find(params[:id])
  end

  def update
    @forum = Forum.find(params[:id])
    @forum.attributes = params[:forum]
    if @forum.save
      flash[:success] = "Forum modifié"
      redirect_to admin_forums_url
    else
      render :edit
    end
  end

  def destroy
    forum = Forum.find(params[:id])
    forum.destroy
    flash[:success] = "Forum supprimé"
    redirect_to admin_forums_url
  end

end
