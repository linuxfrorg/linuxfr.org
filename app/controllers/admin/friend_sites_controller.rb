class Admin::FriendSitesController < AdminController

  def index
    @friend_sites = FriendSite.sorted.all
  end

  def new
    @friend_site = FriendSite.new
  end

  def create
    @friend_site = FriendSite.new
    @friend_site.attributes = params[:friend_site]
    if @friend_site.save
      @friend_site.move_to_bottom
      redirect_to admin_friend_sites_url, :notice => "Site ami créé"
    else
      flash.now[:alert] = "Impossible d'enregistrer ce site"
      render :new
    end
  end

  def edit
    @friend_site = FriendSite.find(params[:id])
  end

  def update
    @friend_site = FriendSite.find(params[:id])
    @friend_site.attributes = params[:friend_site]
    if @friend_site.save
      redirect_to admin_friend_sites_url, :notice => "Site ami modifié"
    else
      flash.now[:alert] = "Impossible d'enregistrer ce site"
      render :edit
    end
  end

  def destroy
    site = FriendSite.find(params[:id])
    site.destroy
    redirect_to admin_friend_sites_url, :notice => "Site ami supprimé"
  end

  def lower
    site = FriendSite.find(params[:id])
    site.move_lower
    redirect_to admin_friend_sites_url
  end

  def higher
    site = FriendSite.find(params[:id])
    site.move_higher
    redirect_to admin_friend_sites_url
  end

end
