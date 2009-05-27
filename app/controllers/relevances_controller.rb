class RelevancesController < ApplicationController
  before_filter :user_required

  def for
    comment = Comment.find(params[:comment_id])
    Relevance.for(current_user, comment)
    redirect_to :back
  end

  def against
    comment = Comment.find(params[:comment_id])
    Relevance.against(current_user, comment)
    redirect_to :back
  end

end
