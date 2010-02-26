class VotesController < ApplicationController
  respond_to :html, :js

  before_filter :user_required
  before_filter :load_node

  def for
    Vote.for(current_user, @node) if @node.content.votable_by?(current_user)
    respond_to do |wants|
      wants.html { redirect_to_content @node.content }
      wants.js   { render :text => "Merci pour votre vote" }
    end
  end

  def against
    Vote.against(current_user, @node) if @node.content.votable_by?(current_user)
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
