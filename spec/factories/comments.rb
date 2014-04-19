# encoding: UTF-8
#
# == Schema Information
#
# Table name: comments
#
#  id                :integer          not null, primary key
#  node_id           :integer
#  user_id           :integer
#  state             :string(10)       default("published"), not null
#  title             :string(160)      not null
#  score             :integer          default(0), not null
#  answered_to_self  :boolean          default(FALSE), not null
#  materialized_path :string(1022)
#  body              :text(16777215)
#  wiki_body         :text
#  created_at        :datetime
#  updated_at        :datetime
#

FactoryGirl.define do
  factory :comment do
    user
    node { FactoryGirl.create(:post).node }
    sequence(:title)     { |n| "Ceci est le #{n}ème commentaire" }
    sequence(:wiki_body) { |n| "Ceci est le #{n}ème commentaire" }
  end
end
