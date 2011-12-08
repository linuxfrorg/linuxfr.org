class Auth::ClientApplicationsController < InheritedResources::Base
  before_filter :authenticate_account!
  respond_to :html

  protected

  def begin_of_association_chain
    current_account
  end
end
