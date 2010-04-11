class SessionsController < ApplicationController
  include Devise::Controllers::InternalHelpers

  prepend_before_filter :require_no_authentication, :only => [ :new, :create ]
  skip_before_filter :verify_authenticity_token

  # GET /account/sign_in
  def new
    render :new
  end

  # POST /account/sign_in
  def create
    @account   = warden.authenticate!(:scope => :account, :recall => "new")
    # FIXME http://wiki.github.com/hassox/warden/strategies
    # FIXME ~gem/devise-1.1.rc0/lib/devise/strategies/database_authenticatable.rb
    @account ||= Account.try_import_old_password(params[:account])
    sign_in :account, @account
    redirect_to stored_location_for(:account) || root_path, :notice => I18n.t("devise.sessions.signed_in")
  end

  # GET /account/sign_out
  def destroy
    sign_out :account
    redirect_to root_url, :notice => I18n.t("devise.sessions.signed_out")
  end
end
