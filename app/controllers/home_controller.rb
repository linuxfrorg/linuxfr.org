class HomeController < ApplicationController

  def index
    @order  = params[:order] || 'interest'
    @ppp    = News.ppp
    @banner = Banner.random
    @nodes  = Node.visible.paginate(:page => params[:page], :per_page => 10, :order => "#{@order} DESC")
  end

end
