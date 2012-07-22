# encoding: UTF-8
require 'spec_helper'


describe LFMarkdown do
  it "accepts simple wiki syntax" do
    html = LFMarkdown.render("**gras** et _it_")
    html.should == "<p><strong>gras</strong> et <em>it</em></p>\n"
  end

  it "accepts the superscript syntax" do
    html = LFMarkdown.render("1^er et 2^(ème)")
    html.should == "<p>1<sup>er</sup> et 2<sup>ème</sup></p>\n"
  end

  it "accepts the strikethrough syntax" do
    html = LFMarkdown.render("foo ~~not~~ baz")
    html.should == "<p>foo <s>not</s> baz</p>\n"
  end

  it "links automatically URL" do
    html = LFMarkdown.render("http://pierre.tramo.name/")
    html.should == "<p><a href=\"http://pierre.tramo.name/\">http://pierre.tramo.name/</a></p>\n"
  end

  it "transforms [[[]]] to internal wiki links" do
    html = LFMarkdown.render("[[[Linux]]]")
    html.should == "<p><a href=\"/wiki/Linux\" title=\"Lien du wiki interne LinuxFr.org\">Linux</a></p>\n"
  end

  it "transforms [[]] to wikipedia links" do
    html = LFMarkdown.render("[[Linux]]")
    html.should == "<p><a href=\"http://fr.wikipedia.org/wiki/Linux\" title=\"Définition Wikipédia\">Linux</a></p>\n"
  end

  it "transforms [[]] to wikipedia links, even with spaces and accents" do
    html = LFMarkdown.render("[[Paul Erdős]]")
    html.should == "<p><a href=\"http://fr.wikipedia.org/wiki/Paul Erdős\" title=\"Définition Wikipédia\">Paul Erdős</a></p>\n"
  end

  it "transforms [[]] to wikipedia links even for categories (with : . and -)" do
    html = LFMarkdown.render("[[Fichier:HTML5-logo.svg]]")
    html.should == "<p><a href=\"http://fr.wikipedia.org/wiki/Fichier:HTML5-logo.svg\" title=\"Définition Wikipédia\">Fichier:HTML5-logo.svg</a></p>\n"
  end

  it "transforms [[]] to wikipedia links, even with parenthesis" do
    html = LFMarkdown.render("[[Pogo_(danse)]]")
    html.should == "<p><a href=\"http://fr.wikipedia.org/wiki/Pogo_(danse)\" title=\"Définition Wikipédia\">Pogo_(danse)</a></p>\n"
  end

  it "transforms [[]] to wikipedia links, even with quote" do
    html = LFMarkdown.render("[[Loi d'Okun]]")
    html.should == "<p><a href=\"http://fr.wikipedia.org/wiki/Loi d'Okun\" title=\"Définition Wikipédia\">Loi d'Okun</a></p>\n"
  end

  it "transforms [[]] to wikipedia links, even with bang" do
    html = LFMarkdown.render("[[Joomla!]]")
    html.should == "<p><a href=\"http://fr.wikipedia.org/wiki/Joomla!\" title=\"Définition Wikipédia\">Joomla!</a></p>\n"
  end

  it "transforms https link to http for the local domain" do
    html = LFMarkdown.render("[foo](https://#{MY_DOMAIN}/bar)")
    html.should == "<p><a href=\"http://#{MY_DOMAIN}/bar\">foo</a></p>\n"
  end

  it "doesn't transform https link to http on other domains" do
    html = LFMarkdown.render("[foo](https://google.com/bar)")
    html.should == "<p><a href=\"https://google.com/bar\">foo</a></p>\n"
  end

  it "proxifies image" do
    html = LFMarkdown.render("![foo](http://fr.wikipedia.org/apple-touch-icon.png)")
    html.should == "<p><img src=\"//#{IMG_DOMAIN}/img/687474703a2f2f66722e77696b6970656469612e6f72672f6170706c652d746f7563682d69636f6e2e706e67/apple-touch-icon.png\" alt=\"foo\" title=\"Source : http://fr.wikipedia.org/apple-touch-icon.png\" /></p>\n"
  end

  it "doesn't proxify images on the local domain" do
    html = LFMarkdown.render("![foo](/images/linuxfr2_100.png)")
    html.should == "<p><img src=\"/images/linuxfr2_100.png\" alt=\"foo\" /></p>\n"
    html = LFMarkdown.render("![foo](http://#{MY_DOMAIN}/images/linuxfr2_100.png)")
    html.should == "<p><img src=\"http://#{MY_DOMAIN}/images/linuxfr2_100.png\" alt=\"foo\" /></p>\n"
    html = LFMarkdown.render("![foo](https://#{MY_DOMAIN}/images/linuxfr2_100.png)")
    html.should == "<p><img src=\"https://#{MY_DOMAIN}/images/linuxfr2_100.png\" alt=\"foo\" /></p>\n"
  end

  it "leaves underscored words unchanged" do
    html = LFMarkdown.render("foo_bar_baz")
    html.should == "<p>foo_bar_baz</p>\n"
  end

  it "handles single line breaks" do
    html = LFMarkdown.render("foo\nbar\n\nbaz")
    html.should == "<p>foo<br/>\nbar</p>\n\n<p>baz</p>\n"
  end

  it "accepts heading levels from <h2> to <h4>" do
    md = LFMarkdown.render <<EOS
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
    md.should == expected
  end

  it "colorizes code enclosed in ```" do
    md = LFMarkdown.render <<EOS
Mon joli code :

```ruby
class Ruby
end
```
EOS
    md.should == "<p>Mon joli code :</p>\n<pre><code class=\"ruby\"><span class=\"k\">class</span> <span class=\"nc\">Ruby</span>\n<span class=\"k\">end</span>\n</code></pre>"
  end

  it "accepts code with utf-8 encoding" do
    md = LFMarkdown.render <<EOS
```bash
#!/bin/sh
# héhé
```
EOS
    expect { md }.to_not raise_exception
    md.encoding.should == Encoding.find("utf-8")
  end

  it 'accepts \" in code ' do
    md = LFMarkdown.render <<EOS
```perl
"Ceci \\" ne fonctionne pas"
```
EOS
    md.should =~ /Ceci \\&quot; ne/
  end
end
