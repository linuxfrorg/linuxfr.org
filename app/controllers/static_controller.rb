# encoding: utf-8
class StaticController < ApplicationController
  caches_action :show, unless: :account_signed_in?, expires_in: 7.days

  def show
    @page = Page.find_by!(slug: params[:id])
  end

  def submit_content
  end

  def changelog
    @page    = params[:page].to_i
    per_page = 15
    skip     = per_page * @page
    @commits = `cd #{Rails.root} && git log -n #{per_page} --skip=#{skip} --no-merges`
  end

end
