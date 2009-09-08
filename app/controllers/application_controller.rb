# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

require 'html5_helper'


class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  helper_method :url_for_content, :current_user, :current_account_session

  protect_from_forgery
  filter_parameter_logging :password, :password_confirmation

  before_filter :seo_filter

protected

  def seo_filter
    @title    = %w(LinuxFr.org)
    @keywords = %w(Linux Logiciel Libre GNU Free Software Actualité Forum Communauté)
    @feeds    = {}
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
    flash[:notice] = "Cette fonctionnalité est réservée aux utilisateurs loggés"
    redirect_to new_account_session_url
  end

  def anonymous_required
    redirect_to '/' if current_user
  end

  def admin_required
    return if current_user && current_user.admin?
    store_location
    flash[:error] = "Cette fonctionnalité est réservée aux administrateurs du site"
    redirect_to new_account_session_url
  end

  def amr_required
    return if current_user && current_user.amr?
    store_location
    flash[:error] = "Cette fonctionnalité est réservée aux administrateurs, modérateurs et relecteurs"
    redirect_to new_account_session_url
  end

  def store_location
    session[:return_to] = request.get? ? request.request_uri : request.header['Referer']
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

end
