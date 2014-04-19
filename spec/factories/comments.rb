# encoding: UTF-8
#
# == Schema Information
#
# Table name: comments
#
#  id                :integer(4)      not null, primary key
#  node_id           :integer(4)
#  user_id           :integer(4)
#  state             :string(10)      default("published"), not null
#  title             :string(160)     not null
#  score             :integer(4)      default(0), not null
#  answered_to_self  :boolean(1)      default(FALSE), not null
#  materialized_path :string(1022)
#  body              :text
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
