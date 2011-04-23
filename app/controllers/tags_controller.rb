# Encoding: utf-8
#
class TagsController < ApplicationController
  before_filter :authenticate_account!, :except => [:public]
  before_filter :find_node, :only => [:new, :create, :update, :destroy]
  before_filter :find_tag,  :only => [:show, :public, :hide, :update]
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
     wants.json { render :json => { :notice => "Tags ajoutés" } }
     wants.html { redirect_to_content @node.content }
    end
  end

  def update
    @node.taggings.create(:tag_id => @tag.id, :user_id => current_account.user_id)
    respond_to do |wants|
     wants.json { render :json => { :notice => "Tag ajouté" } }
     wants.html { redirect_to_content @node.content }
    end
  end

  def destroy
    @tag = Tag.where(:name => params[:id]).first
    @node.taggings.where(:tag_id => @tag.id, :user_id => current_account.user_id).delete_all if @tag
    respond_to do |wants|
     wants.json { render :json => { :notice => "Tag enlevé" } }
     wants.html { redirect_to_content @node.content }
    end
  end

  # Show all the nodes tagged by the current user
  def index
    @nodes = Node.visible.
                  joins(:taggings).
                  where(:taggings => { :user_id => current_account.user_id }).
                  order(@order).
                  group("nodes.id").
                  page(params[:page])
  end

  # Show all the nodes tagged with the given tag by the current user
  def show
    @nodes = Node.visible.
                  joins(:taggings).
                  where(:taggings => { :user_id => current_account.user_id }).
                  where(:taggings => { :tag_id  => @tag.id }).
                  order(@order).
                  group("nodes.id").
                  page(params[:page])
  end

  # Show all the nodes tagged with the given tag
  def public
    @order = (params[:order] || "created_at") + " DESC"
    @nodes = @tag.nodes.where("nodes.public" => true).order(@order).page(params[:page])
  end

  def hide
    enforce_update_permission(@tag)
    @tag.toggle!("public")
    redirect_to :back, :notice => "La visibilité du tag a bien été modifiée"
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
