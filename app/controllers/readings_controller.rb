# Encoding: utf-8
#
class ReadingsController < ApplicationController
  before_filter :authenticate_account!
  before_filter :find_node, :only => [:destroy]

  def index
  end

  def destroy
    @node.unread_by(current_account.id)
    respond_to do |wants|
     wants.js   { render :nothing => true }
     wants.html { redirect_to_content @node.content }
    end
  end

protected

  def find_node
    @node = Node.find(params[:id])
    enforce_tag_permission(@node.content)
  end

end
