# encoding: UTF-8
class StatisticsController < ApplicationController

  def tracker
    @stats = Statistics::Tracker.new
  end

  def prizes
    @month = params[:month]
    @stats = Statistics::Prizes.new(@month)
  end

end
