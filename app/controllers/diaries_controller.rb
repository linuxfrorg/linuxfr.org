class DiariesController < ApplicationController
  before_filter :login_required, :except => [:index, :show]

  def index
    @diaries = Diary.sorted.paginate :page => params[:page], :per_page => 10
  end

  def show
    @diary = Diary.find(params[:id])
    raise ActiveRecord::RecordNotFound.new unless @diary && @diary.readable_by?(current_user)
  end

  def new
    @preview_mode = false
    @diary = Diary.new
    raise ActiveRecord::RecordNotFound.new unless @diary && @diary.creatable_by?(current_user)
  end

  def create
    @diary = Diary.new
    raise ActiveRecord::RecordNotFound.new unless @diary && @diary.creatable_by?(current_user)
    @diary.attributes = params[:diary]
    @preview_mode = (params[:commit] == 'Prévisualiser')
    if !@preview_mode && @diary.save
      @diary.node = Node.create(:user_id => User.new) #(current_user).id)
      flash[:success] = "Votre journal a bien été créé"
      redirect_to diaries_url
    else
      render :new
    end
  end

  def edit
    @diary = Diary.find(params[:id])
    raise ActiveRecord::RecordNotFound.new unless @diary && @diary.editable_by?(current_user)
  end

  def update
    @diary = Diary.find(params[:id])
    raise ActiveRecord::RecordNotFound.new unless @diary && @diary.editable_by?(current_user)
    @diary.attributes = params[:diary]
    @preview_mode = (params[:commit] == 'Prévisualiser')
    if !@preview_mode && @diary.save
      flash[:success] = "Votre journal a bien été modifié"
      redirect_to diaries_url
    else
      render :edit
    end
  end

  def destroy
    @diary = Diary.find(params[:id])
    raise ActiveRecord::RecordNotFound.new unless @diary && @diary.deletable_by?(current_user)
    @diary.node.destroy # FIXME
    @diary.mark_as_deleted
    flash[:success] = "Votre journal a bien été supprimé"
    redirect_to diaries_url
  end

end
