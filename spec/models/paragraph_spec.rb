# encoding: UTF-8
# == Schema Information
#
# Table name: paragraphs
#
#  id          :integer          not null, primary key
#  news_id     :integer          not null
#  position    :integer
#  second_part :boolean
#  body        :text
#  wiki_body   :text
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
    parts = Paragraph.new(:wiki_body => wiki_body).split_body
    parts.should have(4).items
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
    parts = Paragraph.new(:wiki_body => wiki_body).split_body
    parts.should have(3).items
    parts[0].should == "Titre 1\n=======\n\n"
    parts[1].should == "```ruby\ndef foo\n  puts 'foo'\nend\n\nfoo()\n```\n\n"
    parts[2].should == "Un paragraphe\n"
  end
end
