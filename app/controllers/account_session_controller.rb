class AccountSessionController < ApplicationController
# TODO
#   before_filter :require_no_account, :only => [:new, :create]
#   before_filter :require_account, :only => :destroy

  def new
    @account_session = AccountSession.new
  end

  def create
    @account_session = AccountSession.new(params[:account_session])
    if @account_session.save
      flash[:notice] = "Login successful!"
      redirect_to '/'
    else
      render :action => :new
    end
  end

  def destroy
    current_account_session.destroy
    flash[:notice] = "Logout successful!"
    redirect_to '/'
  end
end
