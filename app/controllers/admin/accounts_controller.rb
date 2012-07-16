# encoding: UTF-8
class Admin::AccountsController < AdminController
  before_filter :load_account, :except => [:index]

  def index
    @accounts = Account.order("created_at DESC").page(params[:page])
  end

  def password
    @account.send_reset_password_instructions
    redirect_to admin_accounts_url, :notice => "Instructions pour changer le mot de passe envoyées"
  end

  def update
    if @account.inactive?
      @account.reactivate!
      redirect_to admin_accounts_url, :notice => "Compte réactivé"
    else
      @account.inactivate!
      redirect_to admin_accounts_url, :notice => "Compte désactivé"
    end
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
