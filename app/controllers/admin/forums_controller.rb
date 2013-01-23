# encoding: UTF-8
class Admin::ForumsController < AdminController
  before_filter :find_forum, :except => [:index, :new, :create]

  def index
    @forums = Forum.sorted.all
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
  end

  def update
    @forum.attributes = params[:forum]
    if @forum.save
      redirect_to admin_forums_url, :notice => "Forum modifié"
    else
      flash.now[:alert] = "Impossible d'enregistrer ce forum"
      render :edit
    end
  end

  def archive
    @forum.archive
    redirect_to admin_forums_url, :notice => "Forum archivé"
  end

  def reopen
    @forum.reopen
    redirect_to admin_forums_url, :notice => "Forum ré-ouvert"
  end

  def destroy
    @forum.destroy
    redirect_to admin_forums_url, :notice => "Forum supprimé"
  end

  def lower
    @forum.move_lower
    redirect_to admin_forums_url
  end

  def higher
    @forum.move_higher
    redirect_to admin_forums_url
  end

protected

  def find_forum
    @forum = Forum.find(params[:id])
  end

end
