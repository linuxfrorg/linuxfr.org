# encoding: UTF-8
class StatisticsController < ApplicationController

  def tracker
    @stats = Statistics::Tracker.new
  end

  def prizes
    @month = params[:month]
    @stats = Statistics::Prizes.new(@month)
  end

  def users
    @stats = Statistics::Users.new
  end

  def top
    @stats = Statistics::Tops.new
  end

  def moderation
    @stats = Statistics::Moderation.new
    @goals = Statistics::Goals.new
  end

  def contents
    @stats = Statistics::Contents.new
  end

  def comments
    @stats = Statistics::Comments.new
  end

  def tags
    @stats = Statistics::Tags.new
  end
end
