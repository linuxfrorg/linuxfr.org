class Admin::AccountsController < AdminController

  def index
    @accounts = Account.paginate(:per_page => 20, :page => params[:page], :order => "created_at DESC")
  end

  def update
    @account = Account.find(params[:id])
    if @account.passive?
      @account.activate!
    else
      @account.reactivate!
    end
    redirect_to admin_accounts_url, :notice => "Compte activé"
  end

  def destroy
    @account = Account.find(params[:id])
    @account.delete!
    redirect_to admin_accounts_url, :notice => "Compte supprimé"
  end

end
