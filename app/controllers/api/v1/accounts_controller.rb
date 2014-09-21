class Api::V1::AccountsController < Api::V1::ApiController
  def me
    render json: current_resource_owner.as_json
  end
end
