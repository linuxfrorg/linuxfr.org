# encoding: UTF-8
class Admin::AccountsController < AdminController
  before_action :load_account, except: [:index]

  def index
    accounts = Account
    if params[:login].present?
      @login = params[:login]
      accounts = accounts.where("login LIKE ? COLLATE UTF8_GENERAL_CI", "#{@login}%")
    end
    if params[:date].present?
      @date = params[:date]
      accounts = accounts.where("created_at LIKE ?", "#{@date}%")
    end
    @accounts = accounts.order("created_at DESC").page(params[:page])
  end

  def password
    @account.send_reset_password_instructions
    redirect_to admin_accounts_url, notice: "Instructions pour changer le mot de passe envoyées"
  end

  def karma
    nb = params[:karma] || 50
    @account.give_karma nb
    @account.log_karma nb, current_account
    redirect_to @account.user
  end

  def update
    if @account.inactive?
      @account.reactivate!
      redirect_to :back, notice: "Compte réactivé"
    else
      @account.inactivate!
      redirect_to :back, notice: "Compte désactivé"
    end
  end

  def destroy
    @account.inactivate!
    redirect_to admin_accounts_url, notice: "Compte désactivé"
  end

protected

  def load_account
    @account = Account.find(params[:id])
    @account.amr_id = current_user.id
  end

end
