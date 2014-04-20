# encoding: utf-8
class Admin::ModeratorsController < AdminController
  before_action :load_account

  def create
    @account.give_moderator_rights!
    redirect_to @account.user, notice: "Nouveau rôle : modérateur"
  end

  def destroy
    @account.remove_all_rights!
    redirect_to @account.user, notice: "Rôle retiré : modérateur"
  end

protected

  def load_account
    @account = Account.find(params[:account_id])
  end

end
