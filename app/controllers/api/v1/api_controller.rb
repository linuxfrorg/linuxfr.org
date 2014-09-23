class Api::V1::ApiController < ApplicationController
  skip_before_action :verify_authenticity_token
  respond_to :json

protected

  def current_resource_owner
    Account.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end
end
