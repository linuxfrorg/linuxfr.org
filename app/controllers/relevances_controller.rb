# encoding: utf-8
class RelevancesController < ApplicationController
  respond_to :html, :js

  before_filter :authenticate_account!
  before_filter :load_comment

  def for
    if @comment.votable_by?(current_account)
      @comment.vote_for(current_account)
      notice = "Merci pour votre vote"
    else
      notice = "Vote impossible"
    end
    respond_to do |wants|
      wants.json { render :json => { :notice => notice, :nb_votes => current_account.nb_votes } }
      wants.html { redirect_to :back rescue redirect_to root_url }
    end
  end

  def against
    if @comment.votable_by?(current_account)
      @comment.vote_against(current_account)
      notice = "Merci pour votre vote"
    else
      notice = "Vote impossible"
    end
    respond_to do |wants|
      wants.json { render :json => { :notice => notice, :nb_votes => current_account.nb_votes } }
      wants.html { redirect_to :back rescue redirect_to root_url }
    end
  end

protected

  def load_comment
    @comment = Comment.find(params[:id])
    Rails.logger.info "Relevance on #{params[:id]} #{params[:action]} by #{current_user.id} #{request.remote_ip} at #{Time.now.to_i}"
  end

end
