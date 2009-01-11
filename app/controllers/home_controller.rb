class HomeController < ApplicationController

  def index
    @nodes = Node.by_date.paginate(:page => params[:page], :per_page => 10)
  end

end
