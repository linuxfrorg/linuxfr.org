# encoding: UTF-8
class Moderation::PlonkController < ModerationController
  include ActionView::Helpers::TextHelper

  def create
    nb_days  = (params[:nb_days] || 2).to_i
    @account = Account.find(params[:account_id])
    @account.plonk(nb_days, current_user.id)
    Board.amr_notification("Le compte #{@account.login} #{user_url @account.login} a été plonké pendant #{pluralize nb_days, "jour"} par #{current_user.name} #{user_url(current_user)}")
    render json: { notice: "#{@account.login} a été plonké pendant #{pluralize nb_days, "jour"}" }
  end
end
