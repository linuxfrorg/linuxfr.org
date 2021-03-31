# encoding: utf-8
#
class TagsController < ApplicationController
  before_action :authenticate_account!, except: [:public]
  before_action :find_node, only: [:new, :create, :update, :destroy]
  before_action :find_tag,  only: [:show, :public, :hide, :update]
  before_action :get_order, only: [:index, :show]
  before_action :user_tags, only: [:index, :show]
  respond_to :html, :atom

  def new
    @tag = @node.tags.build
    render partial: 'form' if request.xhr?
  end

  def create
    current_account.tag(@node, params[:tags])
    if request.xhr?
      render partial: 'link'
    else
      redirect_to_content @node.content
    end
  end

  def update
    @node.taggings.create(tag_id: @tag.id, user_id: current_account.user_id)
    respond_to do |wants|
     wants.json { render json: { notice: "Étiquette ajoutée" } }
     wants.html { redirect_to_content @node.content }
    end
  end

  def destroy
    @tag = Tag.where(name: params[:id]).first
    @node.taggings.where(tag_id: @tag.id, user_id: current_account.user_id).destroy_all if @tag
    respond_to do |wants|
     wants.json { render json: { notice: "Étiquette enlevée" } }
     wants.html { redirect_to_content @node.content }
    end
  end

  def autocomplete
    nb = params[:limit].to_i
    nb = 10 if nb <= 0
    @tags = Tag.autocomplete(params[:q], nb)
    render inline: @tags.join("\n")
  end

  # Show all the nodes tagged by the current user
  def index
    @nodes = Node.visible.
                  joins(:taggings).
                  where(taggings: { user_id: current_account.user_id }).
                  order(@order).
                  group("nodes.id").
                  page(params[:page])
  end

  # Show all the nodes tagged with the given tag by the current user
  def show
    @nodes = Node.visible.
                  joins(:taggings).
                  where(taggings: { user_id: current_account.user_id }).
                  where(taggings: { tag_id: @tag.id }).
                  order(@order).
                  group("nodes.id").
                  page(params[:page])
  end

  # Show all the nodes tagged with the given tag
  def public
    @order = params[:order]
    @order = "created_at" unless VALID_ORDERS.include?(@order)
    @dont_index = !@tag.public
    @nodes = @tag.nodes.where("nodes.public" => true).order("#{@order} DESC").page(params[:page])
    respond_with(@nodes)
  end

  def hide
    enforce_update_permission(@tag)
    @tag.toggle!("public")
    Board.amr_notification("L’étiquette #{@tag.name} #{public_tag_url(@tag.name)} est désormais #{@tag.public ? "visible" : "cachée"}, modifiée par #{current_user.name} #{user_url(current_user)}")
    redirect_back fallback_location: root_url, notice: "La visibilité de l’étiquette a bien été modifiée"
  rescue
    redirect_to root_url
  end

protected

  def find_node
    @node = Node.find(params[:node_id])
    enforce_tag_permission(@node.content)
  end

  def find_tag
    @tag = Tag.find_by!(name: params[:id])
  end

  def get_order
    default = current_account.try(:sort_by_date_on_home) ? "taggings.created_at" : "nodes.interest"
    @order = "#{default} DESC"
    @order = "nodes.#{params[:order]} DESC" if VALID_ORDERS.include? params[:order]
  end

  def user_tags
    @tags = current_user.tags.order("name ASC")
  end

end
