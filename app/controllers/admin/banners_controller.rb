class Admin::BannersController < AdminController

  def index
    @banners = Banner.all
  end

  def new
    @preview_mode = false
    @banner = Banner.new
  end

  def create
    @banner = Banner.new(params[:banner])
    @preview_mode = (params[:commit] == 'Prévisualiser')
    if !@preview_mode && @banner.save
      flash[:notice] = 'Nouvelle bannière créée.'
      redirect_to admin_banners_url
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
    @preview_mode = (params[:commit] == 'Prévisualiser')
    if !@preview_mode && @banner.save
      flash[:notice] = 'Bannière mise à jour.'
      redirect_to admin_banners_url
    else
      render :edit
    end
  end

  def destroy
    @banner = Banner.find(params[:id])
    @banner.destroy
    flash[:notice] = 'Bannière supprimée'
    redirect_to admin_banners_url
  end

end
