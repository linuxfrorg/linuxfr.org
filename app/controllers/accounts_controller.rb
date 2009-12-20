class AccountsController < ApplicationController
  before_filter :load_account_by_token, :only => [:activate, :reset_password, :destroy]
  before_filter :anonymous_required,  :except => [:edit, :update, :delete, :destroy]
  before_filter :user_required,         :only => [:edit, :update, :delete, :destroy]

  def new
    @account = Account.new
  end
 
  def create
    @account = Account.new(params[:account])
    if @account.save
      AccountNotifications.deliver_signup(@account)
      redirect_to '/', :notice => "Votre compte a été créé. Vous allez recevoir un email avec les informations pour l'activer"
    else
      render :new
    end
  end

  def activate
    if @account && @account.activate!
      AccountSession.create(@account, true)
      redirect_to '/', :notice => "Votre compte a bien été activé"
    else
      flash.now[:alert] = "Désolé, le lien d'activation n'est pas valide"
      render :forgot_password
    end
  end

  def forgot_password
  end

  def send_password
    @account = Account.find_by_login(params[:login])
    if @account
      @account.reset_perishable_token!
      AccountNotifications.deliver_forgot_password(@account)
      redirect_to '/', :notice => "Vous allez recevoir un email avec un lien pour changer votre mot de passe"
    else
      flash.now[:alert] = "Désolé, ce login ne correspond à aucun compte actif"
      render :forgot_password
    end
  end

  def reset_password
    if @account && @account.active?
      AccountSession.create(@account, true)
      redirect_to edit_account_url, :notice => "Veuillez changer votre mot de passe"
    else
      flash.now[:alert] = "Désolé, ce lien n'est pas/plus valide"
      render :forgot_password
    end
  end

  def edit
    @account = current_account_session.account
  end

  def update
    @account = current_account_session.account
    @account.attributes = params[:account]
    if @account.save
      redirect_to :edit, :notice => "Vos préférences ont été enregistrées"
    else
      flash.now[:alert] = "Impossible d'enregistrer vos préférences !"
      render :edit
    end
  end

  def delete
    @account = current_account_session.account
    @account.reset_perishable_token!
  end

  def destroy
    if @account && @account.id  == current_account_session.account.id
      @account.delete
      current_account_session.destroy
      redirect_to '/', :notice => "Votre compte a bien été supprimé"
    else
      redirect_to :back, :alert => "Le code aléatoire n'est pas le bon"
    end
  end

protected

  def load_account_by_token
    @account = Account.find_using_perishable_token(params[:token])
  end

end
