# encoding: utf-8
class Admin::ModeratorsController < AdminController
  before_action :load_account

  def create
    @account.give_moderator_rights!
    Board.amr_notification("Le compte #{@account.login} #{user_url @account.login} a reçu le rôle modérateur par #{current_user.name} #{user_url(current_user)}")
    redirect_to @account.user, notice: "Nouveau rôle : modérateur"
  end

  def destroy
    @account.remove_all_rights!
    Board.amr_notification("Le compte #{@account.login} #{user_url @account.login} a perdu le rôle modérateur par #{current_user.name} #{user_url(current_user)}")
    redirect_to @account.user, notice: "Rôle retiré : modérateur"
  end

protected

  def load_account
    @account = Account.find(params[:account_id])
  end

end
