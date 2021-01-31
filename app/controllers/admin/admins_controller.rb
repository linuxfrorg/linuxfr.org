# encoding: utf-8
class Admin::AdminsController < AdminController
  before_action :load_account

  def create
    @account.give_admin_rights!
    Board.amr_notification("Le compte #{@account.login} #{user_url @account.login} a reçu le rôle admin par #{current_user.name} #{user_url(current_user)}")
    redirect_to @account.user, notice: "Nouveau rôle : admin"
  end

  def destroy
    @account.remove_all_rights!
    Board.amr_notification("Le compte #{@account.login} #{user_url @account.login} a perdu le rôle admin par #{current_user.name} #{user_url(current_user)}")
    redirect_to @account.user, notice: "Rôle retiré : admin"
  end

protected

  def load_account
    @account = Account.find(params[:account_id])
  end

end
