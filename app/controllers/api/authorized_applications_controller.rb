class Api::AuthorizedApplicationsController < ApplicationController
  before_action :authenticate_account!

  def destroy
    Doorkeeper::AccessToken.revoke_all_for params[:id], current_account
    redirect_to edit_account_registration_path, notice: "L'autorisation a bien été révoquée"
  end
end
