class SessionsController < ApplicationController
  include Devise::Controllers::InternalHelpers

  prepend_before_filter :require_no_authentication, :only => [:new, :create]
  skip_before_filter    :verify_authenticity_token, :only => [:new, :create]

  # GET /account/sign_in
  def new
    render :new
  end

  # POST /account/sign_in
  def create
    cookies[:ssl] = { :value => "on", :secure => false } if request.ssl?
    @account = warden.authenticate!(:scope => :account, :recall => "new")
    sign_in :account, @account
    redirect_to stored_location_for(:account) || root_path, :notice => I18n.t("devise.sessions.signed_in")
  end

  # GET /account/sign_out
  def destroy
    cookies.delete :ssl
    sign_out :account
    redirect_to root_url, :notice => I18n.t("devise.sessions.signed_out")
  end
end
