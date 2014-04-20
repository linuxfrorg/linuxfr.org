# encoding: utf-8
class Admin::AdminsController < AdminController
  before_action :load_account

  def create
    @account.give_admin_rights!
    redirect_to @account.user, notice: "Nouveau rôle : admin"
  end

  def destroy
    @account.remove_all_rights!
    redirect_to @account.user, notice: "Rôle retiré : admin"
  end

protected

  def load_account
    @account = Account.find(params[:account_id])
  end

end
