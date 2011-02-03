class RelevancesController < ApplicationController
  respond_to :html, :js

  before_filter :authenticate_account!
  before_filter :load_comment

  def for
    @comment.vote_for(current_account) if @comment.votable_by?(current_account)
    respond_to do |wants|
      wants.html { redirect_to :back }
      wants.json { render :json => "Merci pour votre vote".to_json }
    end
  end

  def against
    @comment.vote_against(current_account) if @comment.votable_by?(current_account)
    respond_to do |wants|
      wants.html { redirect_to :back }
      wants.json { render :json => "Merci pour votre vote".to_json }
    end
  end

protected

  def load_comment
    @comment = Comment.find(params[:id])
  end

end
