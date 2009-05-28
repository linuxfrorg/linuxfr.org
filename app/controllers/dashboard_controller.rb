class DashboardController < ApplicationController
  before_filter :user_required

  def index
    @comments = current_user.comments.on_dashboard.all(:limit => 20)
    @posts    = current_user.nodes.on_dashboard('Post').all(:limit => 10)
    @trackers = current_user.nodes.on_dashboard('Tracker').all(:limit => 10)
  end

end
