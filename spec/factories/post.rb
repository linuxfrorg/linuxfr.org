# encoding: UTF-8
FactoryGirl.define do
  factory :post do
    title "Ma demande d'aide sur le forum"
    wiki_body "Ça marche pas!!"
    tmp_owner_id 1
    forum
  end
end
