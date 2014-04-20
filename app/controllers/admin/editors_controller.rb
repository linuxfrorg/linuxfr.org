# encoding: utf-8
class Admin::EditorsController < AdminController
  before_action :load_account

  def create
    @account.give_editor_rights!
    redirect_to @account.user, notice: "Nouveau rôle : rédacteur"
  end

  def destroy
    @account.remove_all_rights!
    redirect_to @account.user, notice: "Rôle retiré : rédacteur"
  end

protected

  def load_account
    @account = Account.find(params[:account_id])
  end

end
