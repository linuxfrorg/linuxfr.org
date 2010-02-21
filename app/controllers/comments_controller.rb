class CommentsController < ApplicationController
  before_filter :user_required, :except => [:index, :show]
  before_filter :find_node
  before_filter :find_comment, :except => [:index, :new, :answer, :create]

  def index
    @comments = @node.comments.published.all(:order => 'id DESC')
    respond_to do |wants|
      wants.html
      wants.atom
    end
  end

  def show
    raise ActiveRecord::RecordNotFound.new unless @comment && @comment.readable_by?(current_user)
  end

  def new
    @comment = @node.comments.build
    raise ActiveRecord::RecordNotFound.new unless @comment.creatable_by?(current_user)
  end

  def answer
    new
    @comment.parent_id = params[:id]
    render :new
  end

  def create
    @comment = @node.comments.build
    raise ActiveRecord::RecordNotFound.new unless @comment.creatable_by?(current_user)
    @comment.attributes = params[:comment]
    @comment.user = current_user
    if !preview_mode && @comment.save
      flash[:notice] = "Votre commentaire a bien été posté"
      redirect_to_content @node.content
    else
      render :new
    end
  end

  def edit
    raise ActiveRecord::RecordNotFound.new unless @comment.editable_by?(current_user)
  end

  def update
    raise ActiveRecord::RecordNotFound.new unless @comment.editable_by?(current_user)
    @comment.attributes = params[:comment]
    if !preview_mode && @comment.save
      flash[:notice] = "Votre commentaire a bien été modifié"
      redirect_to_content @node.content
    else
      render :edit
    end
  end

  def destroy
    raise ActiveRecord::RecordNotFound.new unless @comment.deletable_by?(current_user)
    @comment.mark_as_deleted
    flash[:notice] = "Votre commentaire a bien été supprimé"
    redirect_to_content @node.content
  end

protected

  def find_node
    @node = Node.find(params[:node_id])
  end

  def find_comment
    @comment = @node.comments.find(params[:id])
  end

end
