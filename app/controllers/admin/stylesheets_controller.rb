# encoding: UTF-8
class Admin::StylesheetsController < AdminController

  def show
  end

  def create
    Stylesheet.temporary(current_account, params[:url]) do
      redirect_to "/" + Stylesheet.capture("http://#{MY_DOMAIN}/", cookies)
    end
  end

end
