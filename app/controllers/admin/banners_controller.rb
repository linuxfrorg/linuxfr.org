# encoding: UTF-8
class Admin::BannersController < AdminController
  before_action :load_banner, only: [:update, :destroy]

  def index
    @banners = Banner.all
  end

  def new
    @banner = Banner.new
  end

  def create
    @banner = Banner.new(params[:banner])
    if !preview_mode && @banner.save
      Board.amr_notification("La bannière #{@banner.title} #{admin_banners_url} a été créée par #{current_user.name} #{user_url(current_user)}")
      redirect_to admin_banners_url, notice: 'Nouvelle bannière créée.'
    else
      render :new
    end
  end

  def edit
    @banner = Banner.find(params[:id])
  end

  def update
    @banner.attributes = params[:banner]
    if !preview_mode && @banner.save
      Board.amr_notification("La bannière #{@banner.title} #{admin_banners_url} a été modifiée par #{current_user.name} #{user_url(current_user)}")
      redirect_to admin_banners_url, notice: 'Bannière mise à jour.'
    else
      render :edit
    end
  end

  def destroy
    Board.amr_notification("La bannière #{@banner.title} #{admin_banners_url} a été supprimée par #{current_user.name} #{user_url(current_user)}")
    @banner.destroy
    redirect_to admin_banners_url, notice: 'Bannière supprimée'
  end

protected

  def load_banner
    @banner = Banner.find(params[:id])
  end

end
