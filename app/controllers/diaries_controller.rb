class DiariesController < ApplicationController
  before_filter :user_required, :except => [:index, :show]
  before_filter :find_user, :except => [:index, :new, :create]
  after_filter  :marked_as_read, :only => [:show]

### Global ###

  def index
    @diaries = Diary.sorted.paginate :page => params[:page], :per_page => 10
    respond_to do |wants|
      wants.html
      wants.atom
    end
  end

  def new
    @preview_mode = false
    @diary = current_user.diaries.build
    raise ActiveRecord::RecordNotFound.new unless @diary && @diary.creatable_by?(current_user)
  end

  def create
    @diary = current_user.diaries.build
    raise ActiveRecord::RecordNotFound.new unless @diary && @diary.creatable_by?(current_user)
    @diary.attributes = params[:diary]
    @preview_mode = (params[:commit] == 'Prévisualiser')
    if !@preview_mode && @diary.save
      @diary.node = Node.create(:user_id => current_user.id)
      flash[:success] = "Votre journal a bien été créé"
      redirect_to [@diary.user, @diary]
    else
      @diary.node = Node.new
      render :new
    end
  end

### By user ###

  def show
    @diary = @user.diaries.find(params[:id])
    raise ActiveRecord::RecordNotFound.new unless @diary && @diary.readable_by?(current_user)
  end

  def edit
    @diary = @user.diaries.find(params[:id])
    raise ActiveRecord::RecordNotFound.new unless @diary && @diary.editable_by?(current_user)
  end

  def update
    @diary = @user.diaries.find(params[:id])
    raise ActiveRecord::RecordNotFound.new unless @diary && @diary.editable_by?(current_user)
    @diary.attributes = params[:diary]
    @preview_mode = (params[:commit] == 'Prévisualiser')
    if !@preview_mode && @diary.save
      flash[:success] = "Votre journal a bien été modifié"
      redirect_to [@user, @diary]
    else
      render :edit
    end
  end

  def destroy
    @diary = @user.diaries.find(params[:id])
    raise ActiveRecord::RecordNotFound.new unless @diary && @diary.deletable_by?(current_user)
    @diary.mark_as_deleted
    flash[:success] = "Votre journal a bien été supprimé"
    redirect_to diaries_url
  end

protected

  def find_user
    @user = User.find(params[:user_id])
  end

  def marked_as_read
    current_user.read(@diary.node) if current_user
  end

end
