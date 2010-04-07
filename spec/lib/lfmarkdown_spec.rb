require 'spec_helper'

describe LFMarkdown do
  it "should accept simple wiki syntax" do
    html = LFMarkdown.new("**gras** et _it_").to_html
    html.should == "<p><strong>gras</strong> et <em>it</em></p>\n"
  end

  # FIXME depends of a not yet released version of rdiscount
  #it "should autolink URL" do
  #  html = LFMarkdown.new("http://pierre.tramo.name/").to_html
  #  html.should == "<p><a href=\"http://pierre.tramo.name/\">http://pierre.tramo.name/</a></p>\n"
  #end

  it "should transform [[]] to wikipedia links" do
    html = LFMarkdown.new("[[Linux]]").to_html
    html.should == "<p><a href=\"http://fr.wikipedia.org/wiki/Linux\" title=\"Définition Wikipédia\">Linux</a></p>\n"
  end

  it "should left underscored words unchanged" do
    html = LFMarkdown.new("foo_bar_baz").to_html
    html.should == "<p>foo_bar_baz</p>\n"
  end

  it "should accept heading levels from <h2> to <h5>" do
    md = LFMarkdown.new <<EOS
Title 1
=======

Title 2
-------

### Title 3 ###

text
EOS
    md.to_html.should == "<h2>Title 1</h2>\n\n<h3>Title 2</h3>\n\n<h4>Title 3</h4>\n\n<p>text</p>\n"
  end
end
