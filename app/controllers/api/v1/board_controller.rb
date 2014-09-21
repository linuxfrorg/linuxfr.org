class Api::V1::BoardController < Api::V1::ApiController
  after_action :expire_cache, only: [:create]

  def create
    board = Board.new
    if board.creatable_by?(current_resource_owner)
      board.message = params.require(:message)
      board.user = current_resource_owner.user
      board.user_agent = doorkeeper_token.application.name
      board.save
      render json: { id: board.id }
    else
      render json: { error: "You cannot post on this board" }
    end
  end

protected

  def expire_cache
    expire_page controller: '/boards', action: :show, format: :xml
  end
end
