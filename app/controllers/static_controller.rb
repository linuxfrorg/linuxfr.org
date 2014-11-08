# encoding: utf-8
#
# Display git changelogs
class StaticController < ApplicationController
  def show
    @page = Page.find_by!(slug: params[:id])
  end

  def submit_content
  end

  def changelog
    @page    = params[:page].to_i
    per_page = 15
    skip     = per_page * @page
    IO.popen(['git', '-C', Rails.root.to_s, 'log', '-n', per_page.to_s,
              "--skip=#{skip}", '--no-merges']) do |io|
      @commits = io.read
    end
  end
end
