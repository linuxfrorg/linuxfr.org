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

  it "transforms [[[]]] to internal wiki links" do
    html = LFMarkdown.new("[[[Linux]]]").to_html
    html.should == "<p><a href=\"/wiki/Linux\" title=\"Lien du wiki interne LinuxFr.org\">Linux</a></p>\n"
  end

  it "transforms [[]] to wikipedia links" do
    html = LFMarkdown.new("[[Linux]]").to_html
    html.should == "<p><a href=\"http://fr.wikipedia.org/wiki/Linux\" title=\"Définition Wikipédia\">Linux</a></p>\n"
  end

  it "transforms [[]] to wikipedia links, even with spaces and accents" do
    html = LFMarkdown.new("[[Paul Erdős]]").to_html
    html.should == "<p><a href=\"http://fr.wikipedia.org/wiki/Paul Erdős\" title=\"Définition Wikipédia\">Paul Erdős</a></p>\n"
  end

  it "transforms [[]] to wikipedia links even for categories (with : . and -)" do
    html = LFMarkdown.new("[[Fichier:HTML5-logo.svg]]").to_html
    html.should == "<p><a href=\"http://fr.wikipedia.org/wiki/Fichier:HTML5-logo.svg\" title=\"Définition Wikipédia\">Fichier:HTML5-logo.svg</a></p>\n"
  end

  it "transforms [[]] to wikipedia links, even with parenthesis" do
    html = LFMarkdown.new("[[Pogo_(danse)]]").to_html
    html.should == "<p><a href=\"http://fr.wikipedia.org/wiki/Pogo_(danse)\" title=\"Définition Wikipédia\">Pogo_(danse)</a></p>\n"
  end

  it "transforms [[]] to wikipedia links, even with quote" do
    html = LFMarkdown.new("[[Loi d'Okun]]").to_html
    html.should == "<p><a href=\"http://fr.wikipedia.org/wiki/Loi d'Okun\" title=\"Définition Wikipédia\">Loi d'Okun</a></p>\n"
  end

  it "transforms [[]] to wikipedia links, even with bang" do
    html = LFMarkdown.new("[[Joomla!]]").to_html
    html.should == "<p><a href=\"http://fr.wikipedia.org/wiki/Joomla!\" title=\"Définition Wikipédia\">Joomla!</a></p>\n"
  end

  it "leaves underscored words unchanged" do
    html = LFMarkdown.new("foo_bar_baz").to_html
    html.should == "<p>foo_bar_baz</p>\n"
  end

  it "handles single line breaks" do
    html = LFMarkdown.new("foo\nbar\n\nbaz").to_html
    html.should == "<p>foo<br/>\nbar</p>\n\n<p>baz</p>\n"
  end

  it "accepts heading levels from <h2> to <h4>" do
    md = LFMarkdown.new <<EOS
Title 1
=======

Title 2
-------

### Title 3 ###

text
EOS
    expected = <<EOS
<h2 id="toc_0">Title 1</h2>

<h3 id="toc_1">Title 2</h3>

<h4 id="toc_2">Title 3</h4>

<p>text</p>
EOS
    md.to_html.should == expected
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

  it 'accepts \" in code ' do
    md = LFMarkdown.new <<EOS
```perl
"Ceci \\" ne fonctionne pas"
```
EOS
    md.to_html.should =~ /Ceci \\&quot; ne/
  end
end
