# encoding: UTF-8
class Admin::AccountsController < AdminController
  before_action :load_account, except: [:index]

  def index
    accounts = Account
    if params[:login].present?
      @login = params[:login]
      accounts = accounts.where("login LIKE ? COLLATE UTF8MB4_UNICODE_CI", "#{@login}%")
    end
    if params[:date].present?
      @date = params[:date]
      accounts = accounts.where("created_at LIKE ?", "#{@date}%")
    end
    if params[:ip].present?
      @ip = params[:ip]
      accounts = accounts.where("current_sign_in_ip LIKE ? OR last_sign_in_ip LIKE ?", "#{@ip}%", "#{@ip}%")
    end
    if params[:email].present?
      @email = params[:email]
      accounts = accounts.where("email LIKE ?", "%#{@email}%")
    end
    if params[:inactive].present?
      @inactive = params[:inactive]
      accounts = accounts.where("role = 'inactive'")
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
      redirect_back notice: "Compte réactivé", fallback_location: admin_accounts_url
    else
      @account.inactivate!
      redirect_back notice: "Compte désactivé", fallback_location: admin_accounts_url
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
