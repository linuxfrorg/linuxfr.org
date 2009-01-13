class CommentsController < ApplicationController
  before_filter :login_required, :except => [:index, :show]
  before_filter :find_node

  def index
    @comments = @node.comments.roots
  end

  def show
    @comment = @node.comments.find(params[:id])
    raise ActiveRecord::RecordNotFound.new unless @comment && @comment.readable_by?(current_user)
  end

  def new
    @preview_mode = false
    @comment = @node.comments.build
    if params[:parent_id]
      parent = Comment.find(params[:parent_id])
      @comment.parent_id = parent.id
      @comment.title = "Re: #{parent.title}"
    end
    raise ActiveRecord::RecordNotFound.new unless @comment.creatable_by?(current_user)
  end

  def create
    @comment = @node.comments.build
    raise ActiveRecord::RecordNotFound.new unless @comment.creatable_by?(current_user)
    @comment.attributes = params[:comment]
    @preview_mode = (params[:commit] == 'Prévisualiser')
    if !@preview_mode && @comment.save
      if !params[:comment][:parent_id].blank?
        parent = Comment.find(params[:comment][:parent_id])
        @comment.move_to_child_of(parent)
      end
      flash[:success] = "Votre commentaire a bien été posté"
      redirect_to node_comments_url
    else
      @comment.parent_id = params[:comment][:parent_id]
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
      redirect_to node_comments_url
    else
      render :edit
    end
  end

  def destroy
    @comment = @node.comments.find(params[:id])
    raise ActiveRecord::RecordNotFound.new unless @comment.deletable_by?(current_user)
    @comment.mark_as_deleted
    flash[:success] = "Votre commentaire a bien été supprimé"
    redirect_to node_comments_url
  end

protected

  def find_node
    @node = Node.find(params[:node_id])
  end

end
