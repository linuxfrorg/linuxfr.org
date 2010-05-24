class DiariesController < ApplicationController
  before_filter :authenticate_account!, :except => [:index, :show]
  before_filter :find_diary, :except => [:index, :new, :create]
  after_filter  :marked_as_read, :only => [:show]

### Global ###

  def index
    @order   = params[:order] || 'created_at'
    @diaries = Diary.published.joins(:node).order("nodes.#{@order} DESC").paginate(:page => params[:page], :per_page => 10)
    respond_to do |wants|
      wants.html
      wants.atom
    end
  end

  def new
    @diary = current_user.diaries.build
    enforce_create_permission(@diary)
  end

  def create
    @diary = current_user.diaries.build
    enforce_create_permission(@diary)
    @diary.attributes = params[:diary]
    if !preview_mode && @diary.save
      redirect_to [@diary.user, @diary], :notice => "Votre journal a bien été créé"
    else
      @diary.node = Node.new
      render :new
    end
  end

### By user ###

  def show
    enforce_view_permission(@diary)
    redirect_to [@user, @diary], :status => 301 if !@diary.friendly_id_status.best?
  end

  def edit
    enforce_update_permission(@diary)
  end

  def update
    enforce_update_permission(@diary)
    @diary.attributes = params[:diary]
    if !preview_mode && @diary.save
      redirect_to [@user, @diary], :notice => "Votre journal a bien été modifié"
    else
      render :edit
    end
  end

  def destroy
    enforce_destroy_permission(@diary)
    @diary.mark_as_deleted
    redirect_to diaries_url, :notice => "Votre journal a bien été supprimé"
  end

protected

  def find_diary
    @diary = Diary.find(params[:id], :scope => params[:user_id])
    @user  = @diary.owner
  end

  def marked_as_read
    current_user.read(@diary.node) if current_user
  end

end
