class DashboardController < ApplicationController
  before_filter :authenticate_account!

  def index
    @comments = current_user.comments.on_dashboard.all(:limit => 20)
    @posts    = Node.where(:user_id => current_user.id).on_dashboard('Post').all(:limit => 10)
    @trackers = Node.where(:user_id => current_user.id).on_dashboard('Tracker').all(:limit => 10)
  end

end
