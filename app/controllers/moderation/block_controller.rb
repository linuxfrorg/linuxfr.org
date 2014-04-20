# encoding: UTF-8
class Moderation::BlockController < ModerationController
  include ActionView::Helpers::TextHelper

  def create
    nb_days  = (params[:nb_days] || 2).to_i
    @account = Account.find(params[:account_id])
    @account.block(nb_days, current_user.id)
    render json: { notice: "Les commentaires de #{@account.login} sont bloqués pour #{pluralize nb_days, "jour"}" }
  end
end
