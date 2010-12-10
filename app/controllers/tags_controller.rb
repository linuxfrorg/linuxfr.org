class TagsController < ApplicationController
  before_filter :authenticate_account!, :except => [:public]
  before_filter :find_node, :only => [:new, :create]
  before_filter :find_tag,  :only => [:show, :public]
  before_filter :get_order, :only => [:index, :show]
  before_filter :user_tags, :only => [:index, :show]

  autocomplete_for :tag, :name, :order => "taggings_count DESC"
  alias_method :autocomplete, :autocomplete_for_tag_name

  def new
    @tag = @node.tags.build
    render :partial => 'form' if request.xhr?
  end

  def create
    current_account.tag(@node, params[:tags])
    respond_to do |wants|
     wants.html { redirect_to_content @node.content }
     wants.js { render :nothing => true }
    end
  end

  # Show all the nodes tagged by the current user
  def index
    @nodes = Node.paginate(:select => "DISTINCT nodes.*",
                           :joins => [:taggings],
                           :conditions => {"taggings.user_id" => current_account.user_id,
                                           "nodes.public"     => true},
                           :order => @order,
                           :page => params[:page],
                           :per_page => 15)
  end

  # Show all the nodes tagged with the given tag by the current user
  def show
    @nodes = Node.paginate(:select => "DISTINCT nodes.*",
                           :joins => [:taggings],
                           :conditions => {"taggings.user_id" => current_account.user_id,
                                           "taggings.tag_id"  => @tag.id,
                                           "nodes.public"     => true},
                           :order => @order,
                           :page => params[:page],
                           :per_page => 15)
  end

  # Show all the nodes tagged with the given tag
  def public
    @order = (params[:order] || "created_at") + " DESC"
    @nodes = @tag.nodes.where("nodes.public" => true).paginate(:page => params[:page], :per_page => 15, :order => @order)
  end

protected

  def find_node
    @node = Node.find(params[:node_id])
    enforce_tag_permission(@node.content)
  end

  def find_tag
    @tag = Tag.find_or_initialize_by_name(params[:id])
  end

  def get_order
    @order = (params[:order] ? "nodes.#{params[:order]}" : "taggings.created_at") + " DESC"
  end

  def user_tags
    @tags = current_user.tags.order("taggings_count DESC")
  end

end
