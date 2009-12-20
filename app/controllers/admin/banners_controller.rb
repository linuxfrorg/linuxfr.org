class Admin::BannersController < AdminController

  def index
    @banners = Banner.all
  end

  def new
    @banner = Banner.new
  end

  def create
    @banner = Banner.new(params[:banner])
    if !preview_mode && @banner.save
      redirect_to admin_banners_url, :notice => 'Nouvelle bannière créée.'
    else
      render :new
    end
  end

  def edit
    @preview_mode = true
    @banner = Banner.find(params[:id])
  end

  def update
    @banner = Banner.find(params[:id])
    @banner.attributes = params[:banner]
    if !preview_mode && @banner.save
      redirect_to admin_banners_url, :notice => 'Bannière mise à jour.'
    else
      render :edit
    end
  end

  def destroy
    @banner = Banner.find(params[:id])
    @banner.destroy
    redirect_to admin_banners_url, :notice => 'Bannière supprimée'
  end

end
