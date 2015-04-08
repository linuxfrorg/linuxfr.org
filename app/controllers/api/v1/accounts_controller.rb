class Api::V1::AccountsController < Api::V1::ApiController
  before_action -> { doorkeeper_authorize! :account }

  def me
    render json: current_resource_owner.as_json
  end
end
