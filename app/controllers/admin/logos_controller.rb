class Admin::LogosController < AdminController

  def show
    @logos   = Logo.all
    @current = Logo.image
  end

  def create
    Logo.image = params[:logo]
    redirect_to admin_logo_url, :notice => "Changement de logo enregistré"
  end

end
