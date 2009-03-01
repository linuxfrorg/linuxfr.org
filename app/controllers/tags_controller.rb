class TagsController < ApplicationController
  before_filter :login_required, :except => [:public]
  before_filter :find_node, :only => [:new, :create]

  def new
    @tag = @node.tags.build
  end

  def create
    current_user.tag(@node, params[:tags])
    redirect_to @node.content
  end

  # Show all the nodes tagged by the current user
  def index
    @tags    = current_user.tags
    taggings = Tagging.owned_by(current_user.id)
    @nodes   = taggings.nodes
  end

  # Show all the nodes tagged with the given tag by the current user
  def show
    @tag     = Tag.find_by_name(params[:id])
    taggings = tags.taggings.owned_by(current_user.id)
    @nodes   = taggings.nodes
  end

  # Show all the nodes tagged with the given tag
  def public
    @tag     = Tag.find_by_name(params[:id])
    @nodes   = @tag.nodes
  end

protected

  def find_node
    @node = Node.find(params[:node_id])
    raise ActiveRecord::RecordNotFound unless @node && @node.can_be_tagged_by?(current_user)
  end

end
