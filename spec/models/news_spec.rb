# encoding: UTF-8
# == Schema Information
#
# Table name: news
#
#  id           :integer          not null, primary key
#  state        :string(10)       default("draft"), not null
#  title        :string(160)      not null
#  cached_slug  :string(165)
#  moderator_id :integer
#  section_id   :integer
#  author_name  :string(32)       not null
#  author_email :string(64)       not null
#  body         :text
#  second_part  :text(2147483647)
#  created_at   :datetime
#  updated_at   :datetime
#

#
require 'spec_helper'

describe News do
  before(:each) do
    Paragraph.delete_all
  end

  context "when created in redaction" do
    let(:news) { News.create_for_redaction(FactoryGirl.create :writer_account) }

    before(:all) { FactoryGirl.create(:default_section) }

    it "has two paragraphs, one in each part" do
      news.should have(2).paragraphs
      news.paragraphs.in_first_part.should have(1).item
      news.paragraphs.in_second_part.should have(1).item
    end

    it "has a body and a second part" do
      news.should have(0).errors
      news.body =~ /Vous pouvez éditer/
      news.second_part =~ /Vous pouvez éditer/
    end

    it "has an updated body when a paragraph is added" do
      para = news.paragraphs.first
      para.wiki_body = "Paragraphe un\n\nparagraphe deux\n"
      para.update_by(FactoryGirl.create :moderator)
      news.should have(3).paragraphs
      news.paragraphs.in_first_part.should have(2).item
      news.body =~ /Paragraphe un<\/p>.*<p>paragraphe deux/
    end
  end
end
