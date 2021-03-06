# encoding: UTF-8
class Admin::FriendSitesController < AdminController
  before_action :find_friend_site, except: [:index, :new, :create]

  def index
    @friend_sites = FriendSite.all
  end

  def new
    @friend_site = FriendSite.new
  end

  def create
    @friend_site = FriendSite.new
    @friend_site.attributes = params[:friend_site]
    if @friend_site.save
      @friend_site.move_to_bottom
      Board.amr_notification("Le site ami #{@friend_site.title} #{admin_friend_sites_url} a été créé par #{current_user.name} #{user_url(current_user)}")
      redirect_to admin_friend_sites_url, notice: "Site ami créé"
    else
      flash.now[:alert] = "Impossible d’enregistrer ce site"
      render :new
    end
  end

  def edit
  end

  def update
    @friend_site.attributes = params[:friend_site]
    if @friend_site.save
      Board.amr_notification("Le site ami #{@friend_site.title} #{admin_friend_sites_url} a été modifié par #{current_user.name} #{user_url(current_user)}")
      redirect_to admin_friend_sites_url, notice: "Site ami modifié"
    else
      flash.now[:alert] = "Impossible d’enregistrer ce site"
      render :edit
    end
  end

  def destroy
    Board.amr_notification("Le site ami #{@friend_site.title} #{admin_friend_sites_url} a été supprimé par #{current_user.name} #{user_url(current_user)}")
    @friend_site.destroy
    redirect_to admin_friend_sites_url, notice: "Site ami supprimé"
  end

  def lower
    @friend_site.move_lower
    redirect_to admin_friend_sites_url
  end

  def higher
    @friend_site.move_higher
    redirect_to admin_friend_sites_url
  end

protected

  def find_friend_site
    @friend_site = FriendSite.find(params[:id])
  end
end
