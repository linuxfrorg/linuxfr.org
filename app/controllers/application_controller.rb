class ApplicationController < ActionController::Base
  include Canable::Enforcers

  before_filter :seo_filter
  helper_method :mobile?, :url_for_content, :current_user
  protect_from_forgery # TODO

protected

  def seo_filter
    request.session_options[:secure] = request.ssl?
    @title         = %w(LinuxFr.org)
    @author        = nil
    @keywords      = %w(Linux Logiciel Libre GNU Free Software Actualité Forum Communauté)
    @description   = "L'actualité de Linux et du Logiciel Libre"
    @feeds         = {}
    @last_comments = Comment.footer
    @popular_tags  = Tag.footer
    @friend_sites  = FriendSite.sorted
  end

  def mobile?
    request.subdomains.first == 'm'
  end

### Content ###

  def redirect_to_content(content)
    redirect_to url_for_content(content)
  end

  def url_for_content(content)
    case content
    when Diary: url_for([content.user, content])
    when News:  content.new_record? ? "/news" : url_for(content)
    when Post:  url_for([content.forum, content])
    else        url_for(content)
    end
  end

  def preview_mode
    @preview_mode = (params[:commit] == 'Prévisualiser')
  end

### Authentication & authorizations ###

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_account && current_account.user
  end

  def admin_required
    return if current_user && current_user.admin?
    store_location!(:account)
    redirect_to new_account_session_url, :alert => "Vous ne possédez pas les droits nécessaires pour accéder à cette partie du site"
  end

  def amr_required
    return if current_user && current_user.amr?
    store_location!(:account)
    redirect_to new_account_session_url, :alert => "Vous ne possédez pas les droits nécessaires pour accéder à cette partie du site"
  end

  def writer_required
    return if current_user && (current_user.writer? || current_user.amr?)
    store_location!(:account)
    redirect_to new_account_session_url, :alert => "Vous ne possédez pas les droits nécessaires pour accéder à cette partie du site"
  end

  def enforce_view_permission(resource)
    raise Canable::Transgression unless resource.viewable_by?(current_user)
  end

  def store_location!(scope)
    session[:"#{scope}_return_to"] = attempted_path if request && request.get?
  end
end
