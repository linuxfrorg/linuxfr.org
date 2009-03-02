class CommentsController < ApplicationController
  before_filter :login_required, :except => [:index, :show]
  before_filter :find_node

  def index
    @comments = @node.comments.published.all(:order => 'id DESC')
    respond_to do |wants|
      wants.html
      wants.atom
    end
  end

  def show
    @comment = @node.comments.find(params[:id])
    raise ActiveRecord::RecordNotFound.new unless @comment && @comment.readable_by?(current_user)
  end

  def new
    @preview_mode = false
    @comment = @node.comments.build
    @comment.parent_id = params[:parent_id]
    raise ActiveRecord::RecordNotFound.new unless @comment.creatable_by?(current_user)
  end

  def create
    @comment = @node.comments.build
    raise ActiveRecord::RecordNotFound.new unless @comment.creatable_by?(current_user)
    @comment.attributes = params[:comment]
    @comment.user = current_user
    @preview_mode = (params[:commit] == 'Prévisualiser')
    if !@preview_mode && @comment.save
      flash[:success] = "Votre commentaire a bien été posté"
      redirect_to_content @node.content
    else
      render :new
    end
  end

  def edit
    @comment = @node.comments.find(params[:id])
    raise ActiveRecord::RecordNotFound.new unless @comment.editable_by?(current_user)
  end

  def update
    @comment = @node.comments.find(params[:id])
    raise ActiveRecord::RecordNotFound.new unless @comment.editable_by?(current_user)
    @comment.attributes = params[:comment]
    @preview_mode = (params[:commit] == 'Prévisualiser')
    if !@preview_mode && @comment.save
      flash[:success] = "Votre commentaire a bien été modifié"
      redirect_to_content @node.content
    else
      render :edit
    end
  end

  def destroy
    @comment = @node.comments.find(params[:id])
    raise ActiveRecord::RecordNotFound.new unless @comment.deletable_by?(current_user)
    @comment.mark_as_deleted
    flash[:success] = "Votre commentaire a bien été supprimé"
    redirect_to_content @node.content
  end

protected

  def find_node
    @node = Node.find(params[:node_id])
  end

end
