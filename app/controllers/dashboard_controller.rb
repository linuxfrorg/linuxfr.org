# encoding: utf-8
class DashboardController < ApplicationController
  before_action :authenticate_account!
  before_action :reset_notifications, only: [:index]

  def index
    @self_answer = params[:self] == "1"
    # News
    @candidates = News.where(author_email: current_account.email).candidate
    @drafts   = News.where(author_email: current_account.email).draft
    # Comment threads
    @comments = current_user.comments.on_dashboard.limit(30)
    @comments = @comments.where(answered_to_self: false) unless @self_answer
    # Other nodes
    @nodes = Node.where(user_id: current_user.id).on_dashboard([News, Diary, Bookmark, Post, WikiPage]).limit(10)
    # Trackers can get very old, so keep them in their own dashboard
    @trackers = Node.where(user_id: current_user.id).on_dashboard(Tracker).limit(10)
  end

  def answers
    render json: { node_ids: current_account.answers_node_id }
  end

protected

  def reset_notifications
    current_account.reset_answers_notifications
  end

end
