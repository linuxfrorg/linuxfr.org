# encoding: UTF-8
class Moderation::BlacklistController < ModerationController
  include ActionView::Helpers::TextHelper

  def create
    nb_days  = (params[:nb_days] || 2).to_i
    @account = Account.find(params[:account_id])
    @account.blacklist(nb_days)
    render :json => { :notice => "#{@account.login} a été blacklisté pour #{pluralize nb_days, "jour"}" }
  end
end
