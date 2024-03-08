# encoding: utf-8
require 'uri'

class BookmarksController < ApplicationController
  before_action :authenticate_account!, except: [:index, :show]
  before_action :find_bookmark, except: [:index, :new, :create]
  after_action  :marked_as_read, only: [:show], if: :account_signed_in?
  after_action  :expire_cache, only: [:create, :update, :destroy]
  caches_page   :index, if: Proc.new { |c| c.request.format.atom? && c.request.ssl? && c.request.host == c.request.host.downcase }
  respond_to :html, :atom, :md

### Global ###

  def index
    @order = params[:order]
    @order = "created_at" unless VALID_ORDERS.include?(@order)
    @nodes = Node.public_listing(Bookmark, @order).page(params[:page])
    respond_with(@nodes)
  end

  def new
    @bookmark = current_user.bookmarks.build
    @bookmark.cc_licensed = false
    return not_enough_karma('liens') unless @bookmark.creatable_by?(current_account)
    enforce_create_permission(@bookmark)
  end

  def create
    @bookmark = current_user.bookmarks.build
    return not_enough_karma('liens') unless @bookmark.creatable_by?(current_account)
    enforce_create_permission(@bookmark)
    @bookmark.attributes = bookmark_params
    if !preview_mode && @bookmark.save
      current_account.tag(@bookmark.node, params[:tags])
      redirect_to [@bookmark.owner, @bookmark], notice: "Votre lien a bien été partagé"
    else
      @bookmark.node = Node.new(user_id: current_user.id, cc_licensed: false)
      @bookmark.node.preview_tags = params[:tags]
      @bookmark.valid?
      flash.now[:alert] = "Votre lien semble invalide. Le confimez‑vous ?" unless @bookmark.link =~ /\A#{URI::regexp(['http', 'https'])}\z/
      render :new
    end
  end

### By user ###

  def show
    enforce_view_permission(@bookmark)
    path = user_bookmark_path(@user, @bookmark, format: params[:format])
    redirect_to path, status: 301 if request.path != path
    headers['Link'] = %(<#{user_bookmark_url @user, @bookmark}>; rel="canonical")
    flash.now[:alert] = "Attention, ce lien a été supprimé et n’est visible que par l’équipe d'administration" unless @bookmark.visible?
  end

  def edit
    enforce_update_permission(@bookmark)
  end

  def update
    enforce_update_permission(@bookmark)
    @bookmark.attributes = bookmark_params
    if !preview_mode && @bookmark.save
      redirect_to [@user, @bookmark], notice: "Le lien a bien été modifié"
    else
      flash.now[:alert] = "Impossible d’enregistrer ce lien" if @bookmark.invalid?
      render :edit
    end
  end

  def destroy
    enforce_destroy_permission(@bookmark)
    @bookmark.mark_as_deleted
    Board.amr_notification("Le lien #{user_bookmark_url @user, @bookmark} a été supprimé par #{current_user.name} #{user_url(current_user)}")
    redirect_to bookmarks_url, notice: "Le lien a bien été supprimé"
  end

protected

  def bookmark_params
    params.require(:bookmark).permit(:title, :link, :lang, :cc_licensed)
  end

  def find_bookmark
    @user  = User.find(params[:user_id])
    @bookmark = @user.bookmarks.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    bookmark = Bookmark.find(params[:id])
    redirect_to [bookmark.owner, bookmark]
  end

  def marked_as_read
    current_account.read(@bookmark.node) unless params[:format] == "md"
  end

  def expire_cache
    return if @bookmark.new_record?
    expire_page action: :index, format: :atom
  end
end
