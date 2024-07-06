# encoding: UTF-8
class CommentsController < ApplicationController
  before_action :authenticate_account!, except: [:index, :show, :latest]
  before_action :find_node, except: [:templeet, :latest]
  before_action :find_comment, except: [:index, :new, :answer, :create, :templeet, :latest]

  def index
    @comments = @node.comments.published.order('id DESC')
    respond_to do |wants|
      wants.html
      wants.atom
    end
  end

  def latest
    @comments = Comment.latest.
      page(params[:page]).
      order(created_at: :desc)
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
    if current_account.blocked?
      flash[:alert] = "L’équipe de modération a temporairement bloqué vos commentaires sur le site"
    else
      flash[:alert] = "Impossible de commenter un contenu datant de plus de trois mois"
    end
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
    @comment.attributes = comment_params
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
    return too_old_for_edition('commentaire', @comment.edition_period) unless @comment.updatable_by?(current_account)
    enforce_update_permission(@comment)
  end

  def update
    enforce_update_permission(@comment)
    @comment.attributes = comment_params
    if !preview_mode && @comment.save
      flash[:notice] = "Votre commentaire a bien été modifié"
      redirect_to url_for_content(@node.content) + "#comment-#{@comment.id}"
    else
      flash.now[:alert] = "Impossible d’enregistrer ce commentaire" if @comment.invalid?
      render :edit
    end
  end

  def destroy
    enforce_destroy_permission(@comment)
    @comment.mark_as_deleted
    Board.amr_notification("Le commentaire #{url_for_content(@node.content) + "#comment-#{@comment.id}"} a été masqué par #{current_user.name} #{user_url(current_user)}")
    flash[:notice] = "Votre commentaire a bien été supprimé"
    redirect_to_content @node.content
  end

  def templeet
    comment = Comment.find(params[:id])
    redirect_to [comment.node, comment], status: :moved_permanently
  end

protected

  def comment_params
    params.require(:comment).permit(:title, :wiki_body, :node_id, :parent_id)
  end

  def find_node
    @node = Node.find(params[:node_id])
  end

  def find_comment
    @comment = @node.comments.find(params[:id])
  end
end
