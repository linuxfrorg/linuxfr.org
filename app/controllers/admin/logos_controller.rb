# encoding: UTF-8
class Admin::LogosController < AdminController

  def show
    @logos   = Logo.all
    @current = Logo.image
  end

  def create
    Logo.image = params[:logo]
    Board.amr_notification("Le logo #{admin_logo_url} a été modifié par #{current_user.name} #{user_url(current_user)}")
    redirect_to admin_logo_url, notice: "Changement de logo enregistré"
  end

end
