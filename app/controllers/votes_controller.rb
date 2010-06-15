class VotesController < ApplicationController
  respond_to :html, :js

  before_filter :authenticate_account!
  before_filter :load_node

  def for
    @node.vote_for(current_user) if @node.content.votable_by?(current_user)
    respond_to do |wants|
      wants.html { redirect_to_content @node.content }
      wants.js   { render :text => "Merci pour votre vote" }
    end
  end

  def against
    @node.vote_against(current_user) if @node.content.votable_by?(current_user)
    respond_to do |wants|
      wants.html { redirect_to_content @node.content }
      wants.js   { render :text => "Merci pour votre vote" }
    end
  end

protected

  def load_node
    @node = Node.find(params[:id])
  end

end
