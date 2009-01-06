class DiariesController < ApplicationController

  def index
    @diaries = Diary.ordered.paginate :page => params[:page], :per_page => 10
  end

  def show
    @diary = Diary.find(params[:id])
  end

  def new
    @preview_mode = false
    @diary = Diary.new
  end

  def create
    @diary = Diary.new
    @diary.attributes = params[:diary]
    @preview_mode = (params[:commit] == 'Prévisualiser')
    if !@preview_mode && @diary.save
      @diary.node = Node.create(:user_id => User.new) # current_user.id)
      flash[:success] = "Votre journal a bien été créé"
      redirect_to diaries_url
    else
      render :new
    end
  end

  def edit
    @diary = Diary.find(params[:id])
  end

  def update
    @diary = Diary.find(params[:id])
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
    diary = Diary.find(params[:id])
    diary.node.destroy
    diary.destroy
    flash[:success] = "Votre journal a bien été supprimé"
    redirect_to diaries_url
  end
end
