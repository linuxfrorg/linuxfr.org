# encoding: utf-8
# == Schema Information
#
# Table name: wiki_pages
#
#  id          :integer          not null, primary key
#  title       :string(100)      not null
#  cached_slug :string(105)
#  body        :text(16777215)
#  created_at  :datetime
#  updated_at  :datetime
#

require 'spec_helper'

describe WikiPage do
  it "has internal links, not links to wikipedia" do
    body = FactoryGirl.create(:wiki).body
    body.should =~ /<a href="\/wiki\/Templeet"/
    body.should =~ /<a href="\/wiki\/PierreTramo"/
  end
end
