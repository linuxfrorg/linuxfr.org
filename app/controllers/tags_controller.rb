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

  # TODO add pagination for index, show and public

  # Show all the nodes tagged by the current user
  def index
    @nodes = Node.all(:select => "DISTINCT nodes.*",
                      :joins => [:taggings],
                      :conditions => {"taggings.user_id" =>  current_user.id},
                      :order => "taggings.created_at DESC")
  end

  # Show all the nodes tagged with the given tag by the current user
  def show
    @tag   = Tag.find_by_name(params[:id])
    @nodes = Node.all(:select => "DISTINCT nodes.*",
                      :joins => [:taggings],
                      :conditions => {"taggings.user_id" =>  current_user.id, "taggings.tag_id" => @tag.id},
                      :order => "taggings.created_at DESC")
  end

  # Show all the nodes tagged with the given tag
  def public
    @tag   = Tag.find_by_name(params[:id])
    @nodes = @tag.nodes
  end

protected

  def find_node
    @node = Node.find(params[:node_id])
    raise ActiveRecord::RecordNotFound unless @node && @node.can_be_tagged_by?(current_user)
  end

end
