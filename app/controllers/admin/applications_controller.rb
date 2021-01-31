# encoding: UTF-8
class Admin::ApplicationsController < AdminController
  before_action :load_application, only: [:show, :edit, :update, :destroy]

  def index
    @applications = Doorkeeper::Application.page(params[:page])
  end

  def show
  end

  def edit
  end

  def update
    @application.attributes = params[:doorkeeper_application]
    if @application.save
      Board.amr_notification("L’application #{@application.name} #{admin_applications_url} a été modifiée par #{current_user.name} #{user_url(current_user)}")
      redirect_to admin_applications_url, notice: 'Application mise à jour.'
    else
      render :edit
    end
  end

  def destroy
    Board.amr_notification("L’application #{@application.name} #{admin_applications_url} a été supprimée par #{current_user.name} #{user_url(current_user)}")
    @application.destroy
    redirect_to admin_applications_url, notice: 'Application supprimée'
  end

protected

  def load_application
    @application = Doorkeeper::Application.find(params[:id])
  end

end
