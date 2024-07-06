# encoding: UTF-8
class DiariesController < ApplicationController
  before_action :authenticate_account!, except: [:index, :show]
  before_action :find_diary, except: [:index, :new, :create]
  after_action  :marked_as_read, only: [:show], if: :account_signed_in?
  after_action  :expire_cache, only: [:create, :update, :destroy, :move]
  caches_page   :index, if: Proc.new { |c| c.request.format.atom? && c.request.ssl? && c.request.host == c.request.host.downcase }
  respond_to :html, :atom, :md

### Global ###

  def index
    @order = params[:order]
    @order = "created_at" unless VALID_ORDERS.include?(@order)
    @nodes = Node.public_listing(Diary, @order).page(params[:page])
    respond_with(@nodes)
  end

  def new
    @diary = current_user.diaries.build
    @diary.cc_licensed = true
    return not_enough_karma('journaux') unless @diary.creatable_by?(current_account)
    enforce_create_permission(@diary)
  end

  def create
    @diary = current_user.diaries.build
    return not_enough_karma('journaux') unless @diary.creatable_by?(current_account)
    enforce_create_permission(@diary)
    @diary.attributes = diary_params
    if !preview_mode && @diary.save
      current_account.tag(@diary.node, params[:tags])
      redirect_to [@diary.owner, @diary], notice: "Votre journal a bien été créé"
    else
      @diary.node = Node.new(user_id: current_user.id, cc_licensed: @diary.cc_licensed)
      @diary.node.preview_tags = params[:tags]
      @diary.valid?
      flash.now[:alert] = "Votre journal ne contient pas de liens. Confirmez‑vous que cela est normal ?" unless @diary.body =~ /<a /
      render :new
    end
  end

### By user ###

  def show
    enforce_view_permission(@diary)
    path = user_diary_path(@user, @diary, format: params[:format])
    redirect_to path, status: 301 if request.path != path
    headers['Link'] = %(<#{user_diary_url @user, @diary}>; rel="canonical")
    flash.now[:alert] = "Attention, ce journal a été supprimé et n’est visible que par l’équipe d'administration" unless @diary.visible?
  end

  def edit
    enforce_update_permission(@diary)
  end

  def update
    enforce_update_permission(@diary)
    @diary.attributes = diary_params
    if !preview_mode && @diary.save
      redirect_to [@user, @diary], notice: "Le journal a bien été modifié"
    else
      flash.now[:alert] = "Impossible d'enregistrer ce journal" if @diary.invalid?
      render :edit
    end
  end

  def destroy
    enforce_destroy_permission(@diary)
    @diary.mark_as_deleted
    Board.amr_notification("Le journal #{user_diary_url @user, @diary} a été supprimé par #{current_user.name} #{user_url(current_user)}")
    redirect_to diaries_url, notice: "Le journal a bien été supprimé"
  end

  def convert
    enforce_update_permission(@diary)
    @news = @diary.convert
    if current_account.amr?
      space = :moderation
      space = :redaction if @news.draft?
      redirect_to [space, @news]
    else
      redirect_to "/", notice: "Merci d’avoir proposé ce journal en dépêche"
    end
  rescue
    flash.now[:alert] = "Impossible de proposer ce journal en dépêche"
    render :edit
  end

  def move
    enforce_destroy_permission(@diary)
    @diary.move_to_forum params.require(:post).permit(:forum_id)
    Board.amr_notification("Le journal #{user_diary_url @user, @diary} a été déplacé vers les forums par #{current_user.name} #{user_url(current_user)}")
    redirect_to diaries_url, notice: "Le journal a bien été déplacé vers les forums"
  rescue
    flash.now[:alert] = "Impossible de déplacer ce journal. Avez‑vous bien choisi un forum ?"
    render :edit
  end

protected

  def diary_params
    params.require(:diary).permit(:title, :wiki_body, :cc_licensed)
  end

  def find_diary
    @user  = User.find(params[:user_id])
    @diary = @user.diaries.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    diary = Diary.find(params[:id])
    redirect_to [diary.owner, diary]
  end

  def marked_as_read
    current_account.read(@diary.node) unless params[:format] == "md"
  end

  def expire_cache
    return if @diary.new_record?
    expire_page action: :index, format: :atom
  end
end
