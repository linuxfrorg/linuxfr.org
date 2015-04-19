# encoding: utf-8
class Api::ApplicationsController < InheritedResources::Base
  before_action :authenticate_account!
  respond_to :html

  protected

  def begin_of_association_chain
    current_account
  end

  def application_params
    params.require(:doorkeeper_application).permit(:name, :redirect_uri)
  end
end
