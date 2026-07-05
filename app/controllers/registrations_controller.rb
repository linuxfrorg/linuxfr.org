# encoding: UTF-8
class RegistrationsController < Devise::RegistrationsController

  def create
    honeypot = params[:account].delete(:pot_de_miel)
    if honeypot.present?
      head :no_content
    else
      super
    end
  end

  def edit
    self.resource.totoz_style = cookies.permanent["totoz-type"]
    self.resource.totoz_source = cookies.permanent["totoz-url"]
    super
  end

  def update
    super
    cookies.permanent["totoz-type"] = self.resource.totoz_style
    cookies.permanent["totoz-url"] = self.resource.totoz_source
  end
end
