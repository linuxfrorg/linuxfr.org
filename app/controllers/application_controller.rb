# TODO move this somewhere else
require 'html5_helper'
require 'htmldiff'


class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :seo_filter_and_ssl
  helper_method :url_for_content, :current_user, :current_account_session

protected

  def seo_filter_and_ssl
    ActionController::Base.session_options[:secure] = request.ssl?
    @title         = %w(LinuxFr.org)
    @author        = nil
    @keywords      = %w(Linux Logiciel Libre GNU Free Software Actualité Forum Communauté)
    @description   = "L'actualité de Linux et du Logiciel Libre"
    @feeds         = {}
    @last_comments = Comment.footer
    @popular_tags  = Tag.footer
    @friend_sites  = FriendSite.sorted
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

  def current_account_session
    return @current_account_session if defined?(@current_account_session)
    @current_account_session = AccountSession.find
  end

  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_account_session && current_account_session.user
  end

  def user_required
    return if current_user
    store_location
    redirect_to new_account_session_url, :alert => "Cette fonctionnalité est réservée aux utilisateurs loggés"
  end

  def anonymous_required
    redirect_to '/' if current_user
  end

  def admin_required
    return if current_user && current_user.admin?
    store_location
    redirect_to new_account_session_url, :alert => "Vous ne possédez pas les droits nécessaires pour accéder à cette partie du site"
  end

  def amr_required
    return if current_user && current_user.amr?
    store_location
    redirect_to new_account_session_url, :alert => "Vous ne possédez pas les droits nécessaires pour accéder à cette partie du site"
  end

  def writer_required
    return if current_user && (current_user.writer? || current_user.amr?)
    store_location
    redirect_to new_account_session_url, :alert => "Vous ne possédez pas les droits nécessaires pour accéder à cette partie du site"
  end

  def store_location
    session[:return_to] = request.get? ? request.request_uri : request.header['Referer']
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

end
