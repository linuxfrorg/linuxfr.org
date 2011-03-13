class AdminController < ApplicationController
  before_filter :admin_required

  def index
  end

  def debug
  end
end
