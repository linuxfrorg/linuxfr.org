# encoding: UTF-8
class ApplicationController < ActionController::Base
  include Canable::Enforcers

  protect_from_forgery
  before_filter :seo_filter
  helper_method :url_for_content, :path_for_content, :current_user, :current_stylesheet
  rescue_from Canable::Transgression, :with => :error_403

  VALID_ORDERS = %w(created_at score interest last_commented_at comments_count)
  REVISION     = `git rev-parse HEAD`.chomp

protected

  def error_403
    render :file => "#{Rails.public_path}/errors/403.html", :status => 403, :layout => false
  end

  def seo_filter
    request.session_options[:secure] = request.ssl?
    headers["X-Served-By"] = Process.pid.to_s
    headers["X-Revision"]  = REVISION
    @title         = %w(LinuxFr.org)
    @author        = nil
    @keywords      = %w(Linux Logiciel Libre GNU Free Software Actualité Forum Communauté)
    @description   = "L'actualité du Logiciel Libre et de Linux, sur un site francophone contributif géré par une équipe bénévole par et pour des libristes enthousiastes"
    @feeds         = {}
    @last_comments = Comment.footer
    @popular_tags  = Tag.footer
    @friend_sites  = FriendSite.select([:url, :title])
    @dont_index    = params.has_key?(:order) || (request.headers["User-Agent"] =~ /AppEngine-Google/i)
    @google_plus   = false
  end

  def dont_index?
    !!@dont_index
  end

### Content ###

  def redirect_to_content(content)
    redirect_to url_for_content(content)
  end

  def url_for_content(content, only_path=false)
    opts = { :routing_type => (only_path ? :path : :url) }
    case content
    when Diary then content.new_record? ? "/journaux" : polymorphic_url([content.owner, content], opts)
    when News  then content.new_record? ? "/news" : polymorphic_url(content, opts)
    when Post  then polymorphic_url([content.forum, content], opts)
               else polymorphic_url(content, opts)
    end
  end

  def path_for_content(content)
    url_for_content(content, true)
  end

  def preview_mode
    @preview_mode = (params[:commit] == 'Prévisualiser')
  end

### Authentication & authorizations ###

  def current_user
    current_account.try(:user)
  end

  def admin_required
    return if current_account && current_account.admin?
    store_location!(:account)
    redirect_to new_account_session_url, :alert => "Vous ne possédez pas les droits nécessaires pour accéder à cette partie du site"
  end

  def amr_required
    return if current_account && current_account.amr?
    store_location!(:account)
    redirect_to new_account_session_url, :alert => "Vous ne possédez pas les droits nécessaires pour accéder à cette partie du site"
  end

  def enforce_view_permission(resource)
    raise Canable::Transgression unless resource.viewable_by?(current_account)
  end

  def store_location!(scope)
    session[:"#{scope}_return_to"] = url_for() if request && request.get?
  end

  def handle_unverified_request
    Rails.logger.info "CSRF protection for #{request.remote_ip}: #{form_authenticity_token} // #{params[request_forgery_protection_token]} // #{request.headers['X-CSRF-Token']}"
    super
  end

  def current_stylesheet
    cookies[:stylesheet]
  end
end
