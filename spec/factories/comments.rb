# encoding: UTF-8
FactoryGirl.define do
  factory :comment do
    user
    sequence(:title)     { |n| "Ceci est le #{n}ème commentaire" }
    sequence(:wiki_body) { |n| "Ceci est le #{n}ème commentaire" }
  end
end
