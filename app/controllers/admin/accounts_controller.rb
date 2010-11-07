# encoding: UTF-8
class Admin::AccountsController < AdminController
  before_filter :load_account, :only => [:update, :destroy]

  def index
    @accounts = Account.paginate(:per_page => 20, :page => params[:page], :order => "created_at DESC")
  end

  def update
    if @account.inactive?
      @account.reactivate!
    else
      @account.inactivate!
    end
    redirect_to admin_accounts_url, :notice => "Compte activé"
  end

  # TODO purger un compte
  def destroy
    @account.delete!
    redirect_to admin_accounts_url, :notice => "Compte supprimé"
  end

protected

  def load_account
    @account = Account.find(params[:id])
  end

end
