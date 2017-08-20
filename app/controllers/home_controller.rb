# encoding: utf-8
class HomeController < ApplicationController
  DEFAULT_TYPES = %w(News Poll)

  def index
    @sections = Section.published
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
end
