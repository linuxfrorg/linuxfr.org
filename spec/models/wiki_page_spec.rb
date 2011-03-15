# == Schema Information
#
# Table name: wiki_pages
#
#  id          :integer(4)      not null, primary key
#  title       :string(100)     not null
#  cached_slug :string(105)
#  body        :text
#  created_at  :datetime
#  updated_at  :datetime
#

require 'spec_helper'

describe WikiPage do
  it "has internal links, not links to wikipedia" do
    body = Factory.create(:wiki).body
    body.should =~ /<a href="\/wiki\/Templeet"/
    body.should =~ /<a href="\/wiki\/PierreTramo"/
  end
end
