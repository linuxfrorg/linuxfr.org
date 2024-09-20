# encoding: UTF-8
class Admin::StylesheetsController < AdminController

  def show
  end

  def create
    Stylesheet.temporary(current_account, params[:url]) do
      redirect_to "/" + Stylesheet.capture("#{MY_PUBLIC_URL}/", cookies)
    end
  end

end
