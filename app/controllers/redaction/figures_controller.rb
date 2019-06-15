class Redaction::FiguresController < ApplicationController
  before_action :authenticate_account!
  before_action :load_news

  def edit
    render partial: 'figure_form', locals: {news: @news}
  end

  def update
    params.require(:news).require([:figure_alternative, :figure_caption])
    if params[:news][:figure_image]
      @news.figure_image = params[:news][:figure_image]
    elsif not @news.figure_image?
      error = "Aucune image valide n'a été reçue. Veuillez recommencer avec une image."
      render partial: 'figure', locals: {news: @news, error: error}
      return
    end
    @news.figure_alternative = params[:news][:figure_alternative]
    @news.figure_caption = params[:news][:figure_caption]
    @news.save
    render partial: 'figure', locals: {news: @news}
  end

  def delete
    @news.remove_figure_image!
    @news.figure_alternative = nil
    @news.figure_caption = nil
    @news.save
    namespace = @news.draft? ? :redaction : :moderation
    redirect_to [namespace, @news]
  end

protected

  def load_news
    @news = News.find(params[:id])
    enforce_update_permission(@news)
  end
end
