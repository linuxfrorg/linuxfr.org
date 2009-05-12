class AccountSessionController < ApplicationController
  before_filter :anonymous_required, :only => [:new, :create]
  before_filter :user_required, :only => :destroy

  def new
    @account_session = AccountSession.new
  end

  def create
    @account_session = AccountSession.new(params[:account_session])
    if @account_session.save
      flash[:notice] = "Vous êtes loggé"
      redirect_to '/'
    else
      render :action => :new
    end
  end

  def destroy
    current_account_session.destroy
    flash[:notice] = "Vous êtes déloggé"
    redirect_to '/'
  end

end
