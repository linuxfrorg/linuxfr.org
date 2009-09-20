class TagsController < ApplicationController
  before_filter :user_required, :except => [:public]
  before_filter :find_node, :only => [:new, :create]

  autocomplete_for :tag, :name, :order => "taggings_count DESC"

  def new
    @tag = @node.tags.build
  end

  def create
    current_user.tag(@node, params[:tags])
    redirect_to_content @node.content
  end

  # Show all the nodes tagged by the current user
  def index
    @order = params[:order] ? "nodes.#{params[:order]}" : 'taggings.created_at'
    @nodes = Node.paginate(:select => "DISTINCT nodes.*",
                           :joins => [:taggings],
                           :conditions => {"taggings.user_id" => current_user.id,
                                           "nodes.public"     => true},
                           :order => "#{@order} DESC",
                           :page => params[:page],
                           :per_page => 15)
  end

  # Show all the nodes tagged with the given tag by the current user
  def show
    @order = params[:order] ? "nodes.#{params[:order]}" : 'taggings.created_at'
    @tag   = Tag.find_by_name(params[:id])
    @nodes = Node.paginate(:select => "DISTINCT nodes.*",
                           :joins => [:taggings],
                           :conditions => {"taggings.user_id" => current_user.id,
                                           "taggings.tag_id"  => @tag.id,
                                           "nodes.public"     => true},
                           :order => "#{@order} DESC",
                           :page => params[:page],
                           :per_page => 15)
  end

  # Show all the nodes tagged with the given tag
  def public
    @order = params[:order] || 'created_at'
    @tag   = Tag.find_by_name(params[:id])
    @nodes = @tag.nodes.paginate(:page => params[:page], :per_page => 15, :order => "#{@order} DESC")
  end

protected

  def find_node
    @node = Node.find(params[:node_id])
    raise ActiveRecord::RecordNotFound unless @node && @node.can_be_tagged_by?(current_user)
  end

end
