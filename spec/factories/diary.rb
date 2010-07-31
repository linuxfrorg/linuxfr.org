Factory.define :diary do |f|
  f.title "Mon journal"
  f.wiki_body "Cher journal, mon clavier s'est blo"
  f.association :owner, :factory => :writer
end
