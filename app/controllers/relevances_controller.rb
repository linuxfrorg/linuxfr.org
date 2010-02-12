class RelevancesController < ApplicationController
  before_filter :user_required
  before_filter :load_comment

  def for
    Relevance.for(current_user, @comment) if @comment.votable_by?(current_user)
    redirect_to :back
  end

  def against
    Relevance.against(current_user, @comment) if @comment.votable_by?(current_user)
    redirect_to :back
  end

protected

  def load_comment
    @comment = Comment.find(params[:comment_id])
  end

end
