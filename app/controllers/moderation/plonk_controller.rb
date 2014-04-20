# encoding: UTF-8
class Moderation::PlonkController < ModerationController
  include ActionView::Helpers::TextHelper

  def create
    nb_days  = (params[:nb_days] || 2).to_i
    @account = Account.find(params[:account_id])
    @account.plonk(nb_days, current_user.id)
    render json: { notice: "#{@account.login} a été plonké pour #{pluralize nb_days, "jour"}" }
  end
end
