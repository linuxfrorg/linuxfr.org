# encoding: utf-8
class VotesController < ApplicationController
  respond_to :html, :js

  before_action :authenticate_account!
  before_action :load_node

  def for
    if @node.content.votable_by?(current_account)
      @node.vote_for(current_account)
      notice = "Merci pour votre vote"
    else
      notice = "Vote impossible"
    end
    respond_to do |wants|
      wants.json { render json: { notice: notice, nb_votes: current_account.nb_votes } }
      wants.html { redirect_to_content @node.content }
    end
  end

  def against
    if @node.content.votable_by?(current_account)
      @node.vote_against(current_account)
      notice = "Merci pour votre vote"
    else
      notice = "Vote impossible"
    end
    respond_to do |wants|
      wants.json { render json: { notice: notice, nb_votes: current_account.nb_votes } }
      wants.html { redirect_to_content @node.content }
    end
  end

protected

  def load_node
    @node = Node.find(params[:id])
  end

end
