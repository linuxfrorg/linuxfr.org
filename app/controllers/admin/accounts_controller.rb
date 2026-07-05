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
    Board.amr_notification("Le compte #{@account.login} #{user_url @account.login} a reçu #{nb} points de karma par #{current_user.name} #{user_url(current_user)}")
    redirect_to @account.user
  end

  def update
    if @account.inactive?
      @account.reactivate!
      Board.amr_notification("Le compte #{@account.login} #{user_url @account.login} a été réactivé par #{current_user.name} #{user_url(current_user)}")
      redirect_back notice: "Compte réactivé", fallback_location: admin_accounts_url
    else
      @account.show_email = false
      @account.inactivate!
      user = @account.user
      user.homesite = nil
      user.jabber_id = nil
      user.mastodon_url = nil
      user.save
      Board.amr_notification("Le compte #{@account.login} #{user_url @account.login} a été désactivé par #{current_user.name} #{user_url(current_user)}")
      redirect_back notice: "Compte désactivé", fallback_location: admin_accounts_url
    end
  end

  def destroy
    @account.show_email = false
    @account.inactivate!
    user = @account.user
    user.homesite = nil
    user.jabber_id = nil
    user.mastodon_url = nil
    user.save
    Board.amr_notification("Le compte #{@account.login} #{user_url @account.login} a été désactivé par #{current_user.name} #{user_url(current_user)}")
    redirect_to admin_accounts_url, notice: "Compte désactivé"
  end

protected

  def load_account
    @account = Account.find(params[:id])
    @account.amr_id = current_user.id
  end

end
