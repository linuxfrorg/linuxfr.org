class VotesController < ApplicationController
  before_filter :user_required
  before_filter :load_node

  def for
    Vote.for(current_user, @node) if @node.content.votable_by?(current_user)
    redirect_to_content @node.content
  end

  def against
    Vote.against(current_user, @node) if @node.content.votable_by?(current_user)
    redirect_to_content @node.content
  end

protected

  def load_node
    @node = Node.find(params[:node_id])
  end

end
