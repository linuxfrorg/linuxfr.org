# encoding: UTF-8
class DiariesController < ApplicationController
  before_filter :authenticate_account!, :except => [:index, :show]
  before_filter :find_diary, :except => [:index, :new, :create]
  after_filter  :marked_as_read, :only => [:show], :if => :account_signed_in?
  after_filter  :expire_cache, :only => [:create, :update, :destroy, :move]
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
      redirect_to [@user, @diary], :notice => "Le journal a bien été modifié"
    else
      flash.now[:alert] = "Impossible d'enregistrer ce journal" if @diary.invalid?
      render :edit
    end
  end

  def destroy
    enforce_destroy_permission(@diary)
    @diary.mark_as_deleted
    redirect_to diaries_url, :notice => "Le journal a bien été supprimé"
  end

  def convert
    enforce_update_permission(@diary)
    @news = News.new(:title => @diary.title, :wiki_body => @diary.wiki_body, :section_id => Section.default.id)
    @news.author_name  = @diary.owner.try(:name)
    @news.author_email = @diary.owner.try(:account).try(:email)
    if @news.save
      @news.node.update_attribute(:cc_licenced => true) if @diary.node.cc_licensed?
      @news.links.create :title => "Journal à l'origine de la dépêche", :url => "#{MY_DOMAIN}/users/#{@diary.owner.to_param}/journaux/#{@diary.to_param}", :lang => "fr"
      @news.submit!
      if current_account.amr?
        redirect_to [:moderation, @news]
      else
        redirect_to "/", :notice => "Merci d'avoir proposé ce journal en dépêche"
      end
    else
      flash.now[:alert] = "Impossible de proposer ce journal en dépêche"
      render :edit
    end
  end

  def move
    enforce_destroy_permission(@diary)
    @post = Post.new(params[:post])
    @post.title = @diary.title
    @post.wiki_body = @diary.wiki_body
    if @post.save
      node = @post.node
      node.attributes = @diary.node.attributes.except("id", "content_id", "content_type")
      node.save
      @diary.mark_as_deleted
      redirect_to diaries_url, :notice => "Le journal a bien été déplacé vers les forums"
    else
      flash.now[:alert] = "Impossible de déplacer ce journal. Avez-vous bien choisi un forum ?"
      render :edit
    end
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
