class TagsController < ApplicationController
  before_filter :user_required, :except => [:public]
  before_filter :find_node, :only => [:new, :create]
  before_filter :find_tag,  :only => [:show, :public]
  before_filter :get_order, :only => [:index, :show]

  autocomplete_for :tag, :name, :order => "taggings_count DESC"
  alias_method :autocomplete_for_tag_name, :autocomplete

  def new
    @tag = @node.tags.build
  end

  def create
    current_user.tag(@node, params[:tags])
    redirect_to_content @node.content
  end

  # Show all the nodes tagged by the current user
  def index
    # TODO Rails3
    @nodes = Node.paginate(:select => "DISTINCT nodes.*",
                           :joins => [:taggings],
                           :conditions => {"taggings.user_id" => current_user.id,
                                           "nodes.public"     => true},
                           :order => @order,
                           :page => params[:page],
                           :per_page => 15)
  end

  # Show all the nodes tagged with the given tag by the current user
  def show
    # TODO Rails3
    @nodes = Node.paginate(:select => "DISTINCT nodes.*",
                           :joins => [:taggings],
                           :conditions => {"taggings.user_id" => current_user.id,
                                           "taggings.tag_id"  => @tag.id,
                                           "nodes.public"     => true},
                           :order => @order,
                           :page => params[:page],
                           :per_page => 15)
  end

  # Show all the nodes tagged with the given tag
  def public
    @order = (params[:order] || "created_at") + " DESC"
    @nodes = @tag.nodes.paginate(:page => params[:page], :per_page => 15, :order => @order)
  end

protected

  def find_node
    @node = Node.find(params[:node_id])
    raise ActiveRecord::RecordNotFound unless @node && @node.can_be_tagged_by?(current_user)
  end

  def find_tag
    @tag = Tag.find_by_name(params[:id])
  end

  def get_order
    @order = (params[:order] ? "nodes.#{params[:order]}" : "taggings.created_at") + " DESC"
  end

end
