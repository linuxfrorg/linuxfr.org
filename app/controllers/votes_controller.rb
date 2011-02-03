class VotesController < ApplicationController
  respond_to :html, :js

  before_filter :authenticate_account!
  before_filter :load_node

  def for
    @node.vote_for(current_account) if @node.content.votable_by?(current_account)
    respond_to do |wants|
      wants.html { redirect_to_content @node.content }
      wants.json { render :json => "Merci pour votre vote".to_json }
    end
  end

  def against
    @node.vote_against(current_account) if @node.content.votable_by?(current_account)
    respond_to do |wants|
      wants.html { redirect_to_content @node.content }
      wants.json { render :json => "Merci pour votre vote".to_json }
    end
  end

protected

  def load_node
    @node = Node.find(params[:id])
  end

end
