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
      flash[:notice] = 'Nouvelle réponse créée.'
      redirect_to admin_responses_url
    else
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
      flash[:notice] = 'Réponse mise à jour.'
      redirect_to admin_responses_url
    else
      render :edit
    end
  end

  def destroy
    @response = Response.find(params[:id])
    @response.destroy
    flash[:notice] = 'Réponse supprimée'
    redirect_to admin_responses_url
  end

end
