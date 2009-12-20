class DiariesController < ApplicationController
  before_filter :user_required, :except => [:index, :show]
  before_filter :find_user, :except => [:index, :new, :create]
  after_filter  :marked_as_read, :only => [:show]

### Global ###

  def index
    @order   = params[:order] || 'created_at'
    @diaries = Diary.published.paginate(:page => params[:page], :per_page => 10, :order => "nodes.#{@order} DESC", :joins => :node)
    respond_to do |wants|
      wants.html
      wants.atom
    end
  end

  def new
    @diary = current_user.diaries.build
    raise ActiveRecord::RecordNotFound.new unless @diary && @diary.creatable_by?(current_user)
  end

  def create
    @diary = current_user.diaries.build
    raise ActiveRecord::RecordNotFound.new unless @diary && @diary.creatable_by?(current_user)
    @diary.attributes = params[:diary]
    if !preview_mode && @diary.save
      @diary.create_node(:user_id => current_user.id)
      redirect_to [@diary.user, @diary], :notice => "Votre journal a bien été créé"
    else
      @diary.node = Node.new
      render :new
    end
  end

### By user ###

  def show
    @diary = @user.diaries.find(params[:id])
    raise ActiveRecord::RecordNotFound.new unless @diary && @diary.readable_by?(current_user)
    redirect_to [@user, @diary], :status => 301 if @diary.has_better_id?
  end

  def edit
    @diary = @user.diaries.find(params[:id])
    raise ActiveRecord::RecordNotFound.new unless @diary && @diary.editable_by?(current_user)
  end

  def update
    @diary = @user.diaries.find(params[:id])
    raise ActiveRecord::RecordNotFound.new unless @diary && @diary.editable_by?(current_user)
    @diary.attributes = params[:diary]
    if !preview_mode && @diary.save
      redirect_to [@user, @diary], :notice => "Votre journal a bien été modifié"
    else
      render :edit
    end
  end

  def destroy
    @diary = @user.diaries.find(params[:id])
    raise ActiveRecord::RecordNotFound.new unless @diary && @diary.deletable_by?(current_user)
    @diary.mark_as_deleted
    redirect_to diaries_url, :notice => "Votre journal a bien été supprimé"
  end

protected

  def find_user
    @user = User.find(params[:user_id])
  end

  def marked_as_read
    current_user.read(@diary.node) if current_user
  end

end
