Factory.define :diary do |f|
  f.association :owner, :factory => :writer
  f.title "Mon journal"
  f.wiki_body "Cher journal, mon clavier s'est blo"
end
