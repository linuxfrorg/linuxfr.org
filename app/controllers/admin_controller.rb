# encoding: utf-8
class AdminController < ApplicationController
  before_action :admin_required
  before_action :permit_params

  def index
  end

  def debug
  end

  protected

  def permit_params
    params.permit!
  end
end
