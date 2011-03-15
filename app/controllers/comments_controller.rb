# encoding: UTF-8
class CommentsController < ApplicationController
  before_filter :authenticate_account!, :except => [:index, :show]
  before_filter :find_node, :except => [:templeet]
  before_filter :find_comment, :except => [:index, :new, :answer, :create, :templeet]

  def index
    @comments = @node.comments.published.all(:order => 'id DESC')
    respond_to do |wants|
      wants.html
      wants.atom
    end
  end

  def show
    enforce_view_permission(@comment)
  end

  def new
    @comment = @node.comments.build
    enforce_create_permission(@comment)
  rescue Canable::Transgression
    flash[:alert] = "Impossible de commenter un contenu vieux de plus de 3 mois"
    redirect_to_content @node.content
  end

  def answer
    new
    @comment.parent_id = params[:id]
    render :new if current_account.can_create?(@comment)
  end

  def create
    @comment = @node.comments.build
    enforce_create_permission(@comment)
    @comment.attributes = params[:comment]
    @comment.user = current_account.user
    @comment.default_score
    if !preview_mode && @comment.save
      flash[:notice] = "Votre commentaire a bien été posté"
      redirect_to url_for_content(@node.content) + "#comment-#{@comment.id}"
    else
      @comment.valid?
      render :new
    end
  end

  def edit
    enforce_update_permission(@comment)
  end

  def update
    enforce_update_permission(@comment)
    @comment.attributes = params[:comment]
    if !preview_mode && @comment.save
      flash[:notice] = "Votre commentaire a bien été modifié"
      redirect_to_content @node.content
    else
      flash.now[:alert] = "Impossible d'enregistrer ce commentaire" if @comment.invalid?
      render :edit
    end
  end

  def destroy
    enforce_destroy_permission(@comment)
    @comment.mark_as_deleted
    flash[:notice] = "Votre commentaire a bien été supprimé"
    redirect_to_content @node.content
  end

  def templeet
    comment = Comment.find(params[:id])
    redirect_to [comment.node, comment], :status => :moved_permanently
  end

protected

  def find_node
    @node = Node.find(params[:node_id])
  end

  def find_comment
    @comment = @node.comments.find(params[:id])
  end
end
