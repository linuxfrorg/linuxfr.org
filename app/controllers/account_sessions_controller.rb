class AccountSessionsController < ApplicationController
  before_filter :anonymous_required, :only => [:new, :create]
  before_filter :user_required,    :except => [:new, :create]

  def new
    @account_session = AccountSession.new
  end

  def create
    @account_session = AccountSession.new(params[:account_session])
    if !@account_session.valid?
      Account.try_import_old_password(params[:account_session])
      @account_session = AccountSession.new(params[:account_session])
    end
    if @account_session.save
      redirect_to '/', :notice => "Vous êtes connecté"
    else
      render :action => :new
    end
  end

  def destroy
    current_account_session.destroy
    redirect_to '/', :notice => "Vous êtes déconnecté"
  end

end
