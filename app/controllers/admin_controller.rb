class AdminController < ApplicationController
  before_filter :login_required
  # TODO only admin here

  def index
  end
end
