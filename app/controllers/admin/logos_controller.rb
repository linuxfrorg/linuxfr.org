class Admin::LogosController < AdminController

  def show
    Dir.chdir('public/images') do
      @logos = Dir['logos/*.{png,gif,jpg}']
    end
    @current = Dictionary['logo']
  end

  def create
    Dictionary['logo'] = params[:logo]
    flash[:success] = "Changement de logo enregistré"
    redirect_to admin_logo_url
  end

end
