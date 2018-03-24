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
#  section_id   :integer          not null
#  author_name  :string(32)       not null
#  author_email :string(64)       not null
#  body         :text(4294967295)
#  second_part  :text(4294967295)
#  created_at   :datetime
#  updated_at   :datetime
#  submitted_at :datetime
#

#
require 'spec_helper'

describe News do
  context "when created in redaction" do
    let(:news) { News.create_for_redaction(FactoryGirl.create :writer_account) }

    before(:all) { FactoryGirl.create(:default_section) }

    it "has two paragraphs, one in each part" do
      news.paragraphs.size.should eq(2)
      news.paragraphs.in_first_part.size.should eq(1)
      news.paragraphs.in_second_part.size.should eq(1)
    end

    it "has a body and a second part" do
      news.errors.should be_empty
      news.body =~ /Vous pouvez éditer/
      news.second_part =~ /Vous pouvez éditer/
    end

    it "has an updated body when a paragraph is added" do
      para = news.paragraphs.first
      para.wiki_body = "Paragraphe un\n\nparagraphe deux\n"
      para.update_by(FactoryGirl.create :moderator)
      news.paragraphs.size.should eq(3)
      news.paragraphs.in_first_part.size.should eq(2)
      news.body =~ /Paragraphe un<\/p>.*<p>paragraphe deux/
    end
  end
end
