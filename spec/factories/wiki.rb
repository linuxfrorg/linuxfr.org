Factory.define :wiki, :class => WikiPage do |f|
  f.title "Historique de LinuxFr.org"
  f.wiki_body "Quelques liens :\n\n* [[[Templeet]]]\n* [[[PierreTramo]]]\n"
  f.owner_id 1
  f.message "Draft"
end
