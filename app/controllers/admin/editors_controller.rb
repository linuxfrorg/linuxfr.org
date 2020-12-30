# encoding: utf-8
class Admin::EditorsController < AdminController
  before_action :load_account

  def create
    @account.give_editor_rights!
    Board.amr_notification("Le compte #{@account.login} #{user_url @account.login} a reçu le rôle animateur par #{current_user.name} #{user_url(current_user)}")
    redirect_to @account.user, notice: "Nouveau rôle : animateur"
  end

  def destroy
    @account.remove_all_rights!
    Board.amr_notification("Le compte #{@account.login} #{user_url @account.login} a perdu le rôle animateur par #{current_user.name} #{user_url(current_user)}")
    redirect_to @account.user, notice: "Rôle retiré : animateur"
  end

protected

  def load_account
    @account = Account.find(params[:account_id])
  end

end
