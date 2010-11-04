# encoding: UTF-8
Factory.define :post do |f|
  f.title "Ma demande d'aide sur le forum"
  f.wiki_body "Ça marche pas!!"
  f.association :forum
  f.owner_id 1
end
