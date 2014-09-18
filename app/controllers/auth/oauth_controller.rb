# encoding: utf-8
class Auth::OauthController < ApplicationController
  before_action :authenticate_account!, only: [:authorize, :authorized]
  before_action :find_application, only: [:authorize, :authorized]
  skip_before_action :verify_authenticity_token, only: [:access_token, :board_post]

  def authorize
    @redirect_uri = params[:redirect_uri]
  end

  def authorized
    if params[:commit] == "Accepter"
      AccessGrant.prune!
      @access_grant = current_account.access_grants.create(client_application: @application)
      redirect_to redirect_uri_for params.require(:redirect_uri)
    else
      redirect_to params.require(:redirect_uri)
    end
  end

  def access_token
    @application = ClientApplication.authenticate(params.require(:client_id), params.require(:client_secret))
    render json: {error: "Could not find application"} and return if @application.nil?

    @grant = AccessGrant.authenticate(params.require(:code), @application.id)
    render json: {error: "Could not authenticate access code"} and return if @grant.nil?

    @grant.start_expiry_period!
    render json: @grant.as_json
  end

  def user
    @grant = AccessGrant.find_by(access_token: params.require(:bearer_token))
    if @grant.nil?
      render json: { error: "Could not find access grant for this token" }
    else
      render json: @grant.account.as_json(only: [:login, :email, :created_at])
    end
  end

  def board_post
    @grant = AccessGrant.find_by(access_token: params.require(:bearer_token))
    if @grant.nil?
      render json: { error: "Could not find access grant for this token" }
    else
      board = Board.new
      if board.creatable_by?(@grant.account)
        board.message = params.require(:message)
        board.user = @grant.account.user
        board.user_agent = @grant.client_application.name
        board.save
        board.news.tap {|news| news.node.read_by @grant.account.id if news }
        render json: { id: board.id }
      else
        render json: { error: "You cannot post on this board" }
      end
    end
  end

protected

  def find_application
    @application = ClientApplication.find_by(app_id: params.require(:client_id))
  end

  def redirect_uri_for(uri)
    "#{uri}#{uri['?'] ? '&' : '?'}code=#{@access_grant.code}&response_type=code"
  end
end
