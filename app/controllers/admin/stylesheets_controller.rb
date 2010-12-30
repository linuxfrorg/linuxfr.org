# encoding: UTF-8
class Admin::StylesheetsController < AdminController

  def show
    Rails.logger.info cookies.inspect
  end

  def create
    Stylesheet.temporary(current_account, params[:url]) do
      redirect_to "/" + Stylesheet.capture("http://#{MY_DOMAIN}/", cookies)
    end
  end

end
