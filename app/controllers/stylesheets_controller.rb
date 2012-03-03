# encoding: UTF-8
class StylesheetsController < ApplicationController
  before_filter :authenticate_account!
  before_filter :load_account

  def edit
    @stylesheets = Stylesheet.all
    @current = @account.stylesheet
  end

  def create
    @account.stylesheet = params[:stylesheet]
    if @account.save
      msg = { :notice => "Feuille de style enregistrée" }
    else
      msg = { :alert => "Cette feuille de style n'est pas valide" }
    end
    redirect_to edit_stylesheet_url, msg
  end

  def destroy
    @account.stylesheet = nil
    @account.save
    redirect_to edit_stylesheet_url, :notice => "Feuille de style par défaut"
  end

protected

  def load_account
    @account = current_account
  end

end
