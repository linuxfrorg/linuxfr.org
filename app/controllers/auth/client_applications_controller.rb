# encoding: utf-8
class Auth::ClientApplicationsController < InheritedResources::Base
  before_action :authenticate_account!
  respond_to :html

  protected

  def begin_of_association_chain
    current_account
  end
end
