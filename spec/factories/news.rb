# encoding: utf-8
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

FactoryGirl.define do
  factory :news do
    state 'published'
    title "New release of J2EE"
    wiki_body "Not much to say about it"
    second_part "Nothing here"
    moderator
    section
    author_name "Pierre Tramo"
    author_email "pierre.tramo@dlfp.org"
    after_create do |n|
      n.node.public = true
      n.node.created_at = DateTime.now
      n.node.save
    end
  end
end
