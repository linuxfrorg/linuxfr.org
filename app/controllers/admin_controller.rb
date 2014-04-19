# encoding: utf-8
class AdminController < ApplicationController
  before_action :admin_required

  def index
  end

  def debug
  end
end
