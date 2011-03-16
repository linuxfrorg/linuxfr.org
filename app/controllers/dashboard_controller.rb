class DashboardController < ApplicationController
  before_filter :authenticate_account!

  def index
    @self_answer = params[:self] == "1"
    @comments = current_user.comments.on_dashboard.limit(30)
    @comments = @comments.where(:answered_to_self => false) unless @self_answer
    @posts    = Node.where(:user_id => current_user.id).on_dashboard(Post).limit(10)
    @trackers = Node.where(:user_id => current_user.id).on_dashboard(Tracker).limit(10)
  end

end
