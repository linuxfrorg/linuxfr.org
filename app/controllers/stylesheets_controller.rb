# encoding: UTF-8
class StylesheetsController < ApplicationController
  before_filter :authenticate_account!
  before_filter :load_account

  def create
    @account.uploaded_stylesheet = params[:uploaded_stylesheet]
    if @account.save
      Rails.logger.info @account.uploaded_stylesheet
      msg = { :notice => "Feuille de style enregistrée" }
    else
      msg = { :alert => "Erreur lors de l'enregistrement de la feuille de style" }
    end
    redirect_to edit_stylesheet_url, msg
  end

  def edit
    @stylesheets = Stylesheet.all
    @current = @account.stylesheet
  end

  def update
    if params[:css_session] == "current"
      cookies[:stylesheet] = params[:stylesheet]
      msg = { :notice => "Feuille de style définie pour cette session uniquement" }
    else
      cookies.delete(:stylesheet)
      @account.stylesheet = params[:stylesheet]
      if @account.save
        @account.remove_uploaded_stylesheet!
        msg = { :notice => "Feuille de style enregistrée" }
      else
        msg = { :alert => "Cette feuille de style n'est pas valide" }
      end
    end
    redirect_to edit_stylesheet_url, msg
  end

  def destroy
    cookies.delete(:stylesheet)
    @account.remove_uploaded_stylesheet!
    @account.stylesheet = nil
    @account.save
    redirect_to edit_stylesheet_url, :notice => "Feuille de style par défaut"
  end

protected

  def load_account
    @account = current_account
  end

end
