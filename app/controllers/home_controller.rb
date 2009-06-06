class HomeController < ApplicationController

  def index
    @ppp    = News.ppp
    @banner = Banner.random
    @nodes  = Node.public.by_date.paginate(:page => params[:page], :per_page => 10)
  end

end
