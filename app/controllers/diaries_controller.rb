# encoding: UTF-8
class DiariesController < ApplicationController
  before_filter :authenticate_account!, :except => [:index, :show]
  before_filter :find_diary, :except => [:index, :new, :create]
  after_filter  :marked_as_read, :only => [:show], :if => :account_signed_in?
  after_filter  :expire_cache, :only => [:create, :update, :destroy]
  caches_page   :index, :if => Proc.new { |c| c.request.format.atom? && !c.request.ssl? }
  respond_to :html, :atom

### Global ###

  def index
    @order = params[:order]
    @order = "created_at" unless VALID_ORDERS.include?(@order)
    @nodes = Node.public_listing(Diary, @order).page(params[:page])
    respond_with(@nodes)
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
      redirect_to [@diary.owner, @diary], :notice => "Votre journal a bien été créé"
    else
      @diary.node = Node.new
      @diary.valid?
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
      flash.now[:alert] = "Impossible d'enregistrer ce journal" if @diary.invalid?
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
    @user  = User.find(params[:user_id])
    @diary = @user.diaries.find(params[:id])
  end

  def marked_as_read
    current_account.read(@diary.node)
  end

  def expire_cache
    return if @diary.new_record?
    expire_page :action => :index, :format => :atom
    expire_action :action => :show, :id => @diary, :user_id => @diary.owner
  end
end
