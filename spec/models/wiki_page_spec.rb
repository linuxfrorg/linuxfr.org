require 'spec_helper'

describe WikiPage do
  it "has internal links, not links to wikipedia" do
    body = Factory.create(:wiki).body
    body.should =~ /<a href="\/wiki\/Templeet"/
    body.should =~ /<a href="\/wiki\/PierreTramo"/
  end
end
