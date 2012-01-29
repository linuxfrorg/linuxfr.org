# encoding: utf-8
class SessionsController < DeviseController
  prepend_before_filter :allow_params_authentication!, :only => [:create]
  prepend_before_filter :require_no_authentication,    :only => [:new, :create]
  skip_before_filter    :verify_authenticity_token,    :only => [:new, :create]

  def new
  end

  def create
    cookies.permanent[:https] = { :value => "1", :secure => false } if request.ssl?
    @account = warden.authenticate!(:scope => :account, :recall => "#{controller_path}#new")
    sign_in :account, @account
    redirect_to stored_location_for(:account) || :back, :notice => I18n.t("devise.sessions.signed_in")
  rescue ActionController::RedirectBackError
    redirect_to '/'
  end

  def destroy
    cookies.delete :https
    sign_out :account
    redirect_to "/"
  end
end
