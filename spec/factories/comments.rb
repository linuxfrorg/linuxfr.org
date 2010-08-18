# encoding: UTF-8
Factory.define :comment do |f|
  f.association :user
  f.sequence(:title)     { |n| "Ceci est le #{n}ème commentaire" }
  f.sequence(:wiki_body) { |n| "Ceci est le #{n}ème commentaire" }
end
