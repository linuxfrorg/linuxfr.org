# encoding: UTF-8
require 'spec_helper'

describe LFMarkdown do
  it "accepts simple wiki syntax" do
    html = LFMarkdown.new("**gras** et _it_").to_html
    html.should == "<p><strong>gras</strong> et <em>it</em></p>\n"
  end

  it "links automatically URL" do
    html = LFMarkdown.new("http://pierre.tramo.name/").to_html
    html.should == "<p><a href=\"http://pierre.tramo.name/\">http://pierre.tramo.name/</a></p>\n"
  end

  it "transforms [[]] to wikipedia links" do
    html = LFMarkdown.new("[[Linux]]").to_html
    html.should == "<p><a href=\"http://fr.wikipedia.org/wiki/Linux\" title=\"Définition Wikipédia\">Linux</a></p>\n"
  end

  it "transforms [[]] to wikipedia links, even with spaces and accents" do
    html = LFMarkdown.new("[[Paul Erdős]]").to_html
    html.should == "<p><a href=\"http://fr.wikipedia.org/wiki/Paul%20Erd%C5%91s\" title=\"Définition Wikipédia\">Paul Erdős</a></p>\n"
  end

  it "transforms [[]] to wikipedia links even for categories (with : . and -)" do
    html = LFMarkdown.new("[[Fichier:HTML5-logo.svg]]").to_html
    html.should == "<p><a href=\"http://fr.wikipedia.org/wiki/Fichier:HTML5-logo.svg\" title=\"Définition Wikipédia\">Fichier:HTML5-logo.svg</a></p>\n"
  end

  it "leaves underscored words unchanged" do
    html = LFMarkdown.new("foo_bar_baz").to_html
    html.should == "<p>foo_bar_baz</p>\n"
  end

  it "handles single line breaks" do
    html = LFMarkdown.new("foo\nbar\n\nbaz").to_html
    html.should == "<p>foo<br/>\nbar</p>\n\n<p>baz</p>\n"
  end

  it "accepts heading levels from <h2> to <h5>" do
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

  it "colorizes code enclosed in ```" do
    md = LFMarkdown.new <<EOS
Mon joli code :
```ruby
class Ruby
end
```
EOS
    md.to_html.should == "<p>Mon joli code :<br/>\n<pre><code class=\"ruby\"><span class=\"k\">class</span> <span class=\"nc\">Ruby</span>\n<span class=\"k\">end</span>\n</code></pre></p>\n"
  end

  it "accepts code with utf-8 encoding" do
    md = LFMarkdown.new <<EOS
```bash
#!/bin/sh
# héhé
```
EOS
    expect { md.to_html }.to_not raise_exception
    md.to_html.encoding.should == Encoding.find("utf-8")
  end
end
