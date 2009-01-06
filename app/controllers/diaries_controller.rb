class DiariesController < ApplicationController

  def index
    @diaries = Diary.all
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
      redirect_to diaries_url
    else
      render :edit
    end
  end

  def destroy
    diary = Diary.find(params[:id])
    diary.node.destroy
    diary.destroy
    redirect_to diaries_url
  end
end
