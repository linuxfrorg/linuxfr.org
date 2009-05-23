class AccountsController < ApplicationController
  before_filter :anonymous_required,  :except => [:edit, :update, :destroy]
  before_filter :user_required,         :only => [:edit, :update, :destroy]
  before_filter :load_account_by_token, :only => [:activate, :reset_password]

  def new
    @account = Account.new
  end
 
  def create
    @account = Account.new(params[:account])
    if @account.save
      flash[:notice] = "Votre compte a été créé. Vous allez recevoir un email avec les informations pour l'activer"
      AccountNotifications.deliver_signup(@account) # TODO run_later
      redirect_to '/'
    else
      render :new
    end
  end

  def activate
    if @account && @account.activate!
      AccountSession.create(@account, true)
      flash[:notice] = "Votre compte a bien été activé"
      redirect_to '/'
    else
      flash[:error] = "Désolé, le lien d'activation n'est pas valide"
      render :forgot_password
    end
  end

  def forgot_password
  end

  def send_password
    @account = Account.find_by_login(params[:login])
    if @account
      flash[:notice] = "Vous allez recevoir un email avec un lien pour changer votre mot de passe"
      @account.reset_perishable_token!
      AccountNotifications.deliver_forgot_password(@account) # TODO run_later
      redirect_to '/'
    else
      flash[:error] = "Désolé, ce login ne correspond à aucun compte actif"
      render :forgot_password
    end
  end

  def reset_password
    if @account && @account.active?
      AccountSession.create(@account, true)
      flash[:notice] = "Veuillez changer votre mot de passe"
      redirect_to edit_account_url
    else
      flash[:error] = "Désolé, ce lien n'est pas/plus valide"
      render :forgot_password
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end

protected

  def load_account_by_token
    @account = Account.find_using_perishable_token(params[:token], 24.hours)
  end

end
