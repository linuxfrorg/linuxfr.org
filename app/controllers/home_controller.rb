# encoding: utf-8
class HomeController < ApplicationController
  before_filter :google_plus
  caches_action :index, :unless     => Proc.new {|c| c.account_signed_in? || c.dont_index? },
                        :expires_in => 5.minutes,
                        :cache_path => Proc.new {|c| "home/#{c.params[:order]}/#{c.params[:page]}" }

  DEFAULT_TYPES = %w(News Poll)

  def index
    @types  = current_account.try(:types_on_home)
    @types  = DEFAULT_TYPES if @types.blank?
    default = current_account.try(:sort_by_date_on_home) ? "created_at" : "interest"
    @order  = params[:order]
    @order  = default unless VALID_ORDERS.include?(@order)
    @ppp    = Node.ppp
    @banner = Banner.random
    @poll   = Poll.current
    @nodes  = Node.public_listing(@types, @order).page(params[:page])
  end

protected

  def google_plus
    @google_plus = true
  end

end
