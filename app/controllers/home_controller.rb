class HomeController < ApplicationController
  caches_action :index, :unless     => :account_signed_in?,
                        :expires_in => 5.minutes,
                        :cache_path => Proc.new {|c| "home/#{c.params[:order]}/#{c.params[:page]}" }

  def index
    @order  = params[:order] || 'interest'
    @ppp    = News.ppp
    @banner = Banner.random
    @nodes  = Node.paginate(:page => params[:page], :per_page => 10, :order => "#{@order} DESC")
  end
end
