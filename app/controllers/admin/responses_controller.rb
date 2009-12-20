class Admin::ResponsesController < AdminController

  def index
    @responses = Response.all
  end

  def new
    @response = Response.new
  end

  def create
    @response = Response.new(params[:response])
    if @response.save
      redirect_to admin_responses_url, :notice => 'Nouvelle réponse créée.'
    else
      flash.now[:alert] = "Impossible d'enregistrer cette réponse"
      render :new
    end
  end

  def edit
    @response = Response.find(params[:id])
  end

  def update
    @response = Response.find(params[:id])
    @response.attributes = params[:response]
    if @response.save
      redirect_to admin_responses_url, :notice => 'Réponse mise à jour.'
    else
      flash.now[:alert] = "Impossible d'enregistrer cette réponse"
      render :edit
    end
  end

  def destroy
    @response = Response.find(params[:id])
    @response.destroy
    redirect_to admin_responses_url, :notice => 'Réponse supprimée'
  end

end
