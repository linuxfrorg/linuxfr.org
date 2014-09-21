class Api::V1::ApiController < ApplicationController
  respond_to :json

protected

  def current_resource_owner
    Account.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end
end
