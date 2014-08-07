# encoding: utf-8
class Auth::ClientApplicationsController < InheritedResources::Base
  before_action :authenticate_account!
  respond_to :html

  protected

  def begin_of_association_chain
    current_account
  end

  def client_application_params
    params.require(:client_application).permit(:name)
  end
end
