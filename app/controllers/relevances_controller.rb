class RelevancesController < ApplicationController
  respond_to :html, :js

  before_filter :authenticate_account!
  before_filter :load_comment

  def for
    @comment.vote_for(current_user) if @comment.votable_by?(current_user)
    respond_to do |wants|
      wants.html { redirect_to :back }
      wants.js   { render :text => "Merci pour votre vote" }
    end
  end

  def against
    @comment.vote_against(current_user) if @comment.votable_by?(current_user)
    respond_to do |wants|
      wants.html { redirect_to :back }
      wants.js   { render :text => "Merci pour votre vote" }
    end
  end

protected

  def load_comment
    @comment = Comment.find(params[:id])
  end

end
