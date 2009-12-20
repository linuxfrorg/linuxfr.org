class Admin::LogosController < AdminController

  def show
    Dir.chdir('public/images') do
      @logos = Dir['logos/*.{png,gif,jpg}']
    end
    @current = Dictionary['logo']
  end

  def create
    Dictionary['logo'] = params[:logo]
    redirect_to admin_logo_url, :notice => "Changement de logo enregistré"
  end

end
