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
      redirect_to admin_forums_url, :notice => "Forum créé"
    else
      flash.now[:alert] = "Impossible d'enregistrer ce forum"
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
      redirect_to admin_forums_url, :notice => "Forum modifié"
    else
      flash.now[:alert] = "Impossible d'enregistrer ce forum"
      render :edit
    end
  end

  def destroy
    forum = Forum.find(params[:id])
    forum.destroy
    redirect_to admin_forums_url, :notice => "Forum supprimé"
  end

end
