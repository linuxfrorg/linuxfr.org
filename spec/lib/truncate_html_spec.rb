require "spec_helper"

describe "truncate_html" do
  let(:short_text) { "<p>Foo <b>Bar</b> Baz</p>" }
  let(:long_text)  { "<p>Foo " +  ("<b>Bar Baz</b> " * 100) + "Quux</p>" }
  let(:list_text)  { "<p>Foo:</p><ul>" +  ("<li>Bar Baz</li> " * 100) + "</ul>" }

  it "should not modify short text" do
    truncate_html(short_text, 10).should == short_text
  end

  it "should truncate long text to the given number of words" do
    words = truncate_html(long_text, 10, "").gsub(/<[^>]*>/, '').split
    words.should have(10).items
    words = truncate_html(long_text, 11, "").gsub(/<[^>]*>/, '').split
    words.should have(11).items
  end

  it "should not contains empty DOM nodes" do
    truncate_html(long_text, 10, "...").should_not =~ /<b>\s*<\/b>/
    truncate_html(long_text, 11, "...").should_not =~ /<b>\s*<\/b>/
    truncate_html(list_text, 10, "...").should_not =~ /<li>\s*<\/li>/
    truncate_html(list_text, 11, "...").should_not =~ /<li>\s*<\/li>/
  end

  it "should truncate long text with an ellipsis inside the last DOM node" do
    truncate_html(list_text, 10, "...").should =~ /\.\.\.<\/li>\s*<\/ul>$/
  end

  it "should truncate long text" do
    truncate_html(long_text, 3, "...").should == "<p>Foo <b>Bar Baz</b> <b>...</b></p>"
    truncate_html(long_text, 4, "...").should == "<p>Foo <b>Bar Baz</b> <b>Bar...</b></p>"
    truncate_html(list_text, 3, "...").should == "<p>Foo:</p><ul><li>Bar Baz</li> <li>...</li></ul>"
    truncate_html(list_text, 4, "...").should == "<p>Foo:</p><ul><li>Bar Baz</li> <li>Bar...</li></ul>"
  end

  it "should be possible to truncate with HTML in the ellipsis" do
    truncate_html(long_text, 2, ' <a href="/more">...</a>').should == '<p>Foo <b>Bar <a href="/more">...</a></b></p>'
  end
end
