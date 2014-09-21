class Api::V1::AccountsController < Api::V1::ApiController
  doorkeeper_for :all, scopes: [:account]

  def me
    render json: current_resource_owner.as_json
  end
end
