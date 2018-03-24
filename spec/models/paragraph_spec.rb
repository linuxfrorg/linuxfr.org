# encoding: UTF-8
# == Schema Information
#
# Table name: paragraphs
#
#  id          :integer          not null, primary key
#  news_id     :integer          not null
#  position    :integer
#  second_part :boolean
#  body        :text(16777215)
#  wiki_body   :text(16777215)
#

#
require 'spec_helper'

describe Paragraph do
  it "split wiki_body correctly" do
    wiki_body = <<-EOS
Titre 1
=======

Titre 2
-------

Un paragraphe
qui se continue
sur plusieurs lignes.

Un autre paragraphe.
EOS
    parts = Paragraph.new(wiki_body: wiki_body).split_body
    parts.size.should eq(4)
    parts[0].should == "Titre 1\n=======\n\n"
    parts[1].should == "Titre 2\n-------\n\n"
    parts[2].should == "Un paragraphe\nqui se continue\nsur plusieurs lignes.\n\n"
    parts[3].should == "Un autre paragraphe.\n"
  end

  it "doesn't split code on several paragraphs" do
    wiki_body = <<-EOS
Titre 1
=======

```ruby
def foo
  puts 'foo'
end

foo()
```
Un paragraphe
EOS
    parts = Paragraph.new(wiki_body: wiki_body).split_body
    parts.size.should eq(3)
    parts[0].should == "Titre 1\n=======\n\n"
    parts[1].should == "```ruby\ndef foo\n  puts 'foo'\nend\n\nfoo()\n```\n\n"
    parts[2].should == "Un paragraphe\n"
  end

  it "splits text in paragraphs, even when they are some trailing spaces" do
    parts = Paragraph.new(wiki_body: "## Title ##\n  Foobar\n  \nbaz\n").split_body
    parts.size.should eq(2)
    parts[0].should == "## Title ##\n  Foobar\n  \n"
    parts[1].should == "baz\n"
  end
end
