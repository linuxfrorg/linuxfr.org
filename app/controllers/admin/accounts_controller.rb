# encoding: UTF-8
class Admin::AccountsController < AdminController
  before_filter :load_account, :only => [:update, :destroy]

  def index
    @accounts = Account.order("created_at DESC").page(params[:page])
  end

  def update
    if @account.inactive?
      @account.reactivate!
    else
      @account.inactivate!
    end
    redirect_to admin_accounts_url, :notice => "Compte activé"
  end

  def destroy
    @account.inactivate!
    redirect_to admin_accounts_url, :notice => "Compte désactivé"
  end

protected

  def load_account
    @account = Account.find(params[:id])
  end

end
