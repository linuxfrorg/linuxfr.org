# TODO move this somewhere else
require 'htmldiff'


class ApplicationController < ActionController::Base
  include Canable::Enforcers

  # TODO rails3
  # protect_from_forgery is on by default, says the release notes
  before_filter :seo_filter_and_ssl
  helper_method :mobile?, :url_for_content, :current_user, :current_account_session

protected

  def seo_filter_and_ssl
    # TODO Rails3
    # ActionController::Base.session_options[:secure] = request.ssl?
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
    when News:  content.new_record? ? news_index_path : url_for(content)
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

  alias_method :user_required, :account_signed_in?

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

end
