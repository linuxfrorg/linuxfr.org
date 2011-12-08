class Auth::OauthController < ApplicationController
  before_filter :authenticate_account!, :only => [:authorize, :authorized]
  before_filter :find_application, :only => [:authorize, :authorized]
  skip_before_filter :verify_authenticity_token, :only => [:access_token]

  def authorize
    @redirect_uri = params[:redirect_uri]
  end

  def authorized
    if params[:commit] == "Accepter"
      AccessGrant.prune!
      @access_grant = current_account.access_grants.create(:client_application => @application)
      redirect_to redirect_uri_for(params[:redirect_uri])
    else
      redirect_to params[:redirect_uri]
    end
  end

  def access_token
    @application = ClientApplication.authenticate(params[:client_id], params[:client_secret])
    render :json => {:error => "Could not find application"} and return if @application.nil?

    @grant = AccessGrant.authenticate(params[:code], @application.id)
    render :json => {:error => "Could not authenticate access code"} and return if @grant.nil?

    @grant.start_expiry_period!
    render :json => @grant.as_json
  end

  def user
    @grant = AccessGrant.find_by_access_token(params[:bearer_token])
    if @grant.nil?
      render :json => { :error => "Could not find access grant for this token" }
    else
      render :json => @grant.account.as_json(:only => [:login, :email, :created_at])
    end
  end

protected

  def find_application
    @application = ClientApplication.find_by_app_id(params[:client_id])
  end

  def redirect_uri_for(uri)
    "#{uri}#{uri['?'] ? '&' : '?'}code=#{@access_grant.code}&response_type=code"
  end
end
