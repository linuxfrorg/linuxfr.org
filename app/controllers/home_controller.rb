class HomeController < ApplicationController
  caches_action :index, :unless     => :account_signed_in?,
                        :expires_in => 5.minutes,
                        :cache_path => Proc.new {|c| "home/#{c.params[:order]}/#{c.params[:page]}" }

  def index
    @types  = current_account.try(:types_on_home)
    @types  = %w(News Poll) if @types.blank?
    default = current_account.try(:sort_by_date_on_home) ? "created_at" : "interest"
    @order  = params[:order]
    @order  = default unless VALID_ORDERS.include?(@order)
    @ppp    = News.ppp
    @banner = Banner.random
    @nodes  = Node.public_listing(@types, @order).page(params[:page])
  end
end
