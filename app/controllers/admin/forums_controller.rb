# encoding: UTF-8
class Admin::ForumsController < AdminController
  before_action :find_forum, except: [:index, :new, :create]

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
      Board.amr_notification("Le forum #{@forum.title} #{admin_forums_url} a été créé par #{current_user.name} #{user_url(current_user)}")
      redirect_to admin_forums_url, notice: "Forum créé"
    else
      flash.now[:alert] = "Impossible d’enregistrer ce forum"
      render :new
    end
  end

  def edit
  end

  def update
    @forum.attributes = params[:forum]
    if @forum.save
      Board.amr_notification("Le forum #{@forum.title} #{admin_forums_url} a été modifié par #{current_user.name} #{user_url(current_user)}")
      redirect_to admin_forums_url, notice: "Forum modifié"
    else
      flash.now[:alert] = "Impossible d’enregistrer ce forum"
      render :edit
    end
  end

  def archive
    @forum.archive
    Board.amr_notification("Le forum #{@forum.title} #{admin_forums_url} a été archivé par #{current_user.name} #{user_url(current_user)}")
    redirect_to admin_forums_url, notice: "Forum archivé"
  end

  def reopen
    @forum.reopen
    Board.amr_notification("Le forum #{@forum.title} #{admin_forums_url} a été réouvert par #{current_user.name} #{user_url(current_user)}")
    redirect_to admin_forums_url, notice: "Forum réouvert"
  end

  def destroy
    Board.amr_notification("Le forum #{@forum.title} #{admin_forums_url} a été supprimé par #{current_user.name} #{user_url(current_user)}")
    @forum.destroy
    redirect_to admin_forums_url, notice: "Forum supprimé"
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
