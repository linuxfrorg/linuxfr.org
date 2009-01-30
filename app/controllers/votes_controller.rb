class VotesController < ApplicationController
  before_filter :login_required

  def for
    node = Node.find(params[:node_id])
    Vote.for(current_user, node) if node.content.votable_by?(current_user)
    redirect_to :back
  end

  def against
    node = Node.find(params[:node_id])
    Vote.against(current_user, node) if node.content.votable_by?(current_user)
    redirect_to :back
  end

end
