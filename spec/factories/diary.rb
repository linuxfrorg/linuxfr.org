# encoding: utf-8
FactoryGirl.define do
  factory :diary do
    title "Mon journal"
    wiki_body "Cher journal, mon clavier s'est blo"
    association :owner, factory: :writer
  end
end
