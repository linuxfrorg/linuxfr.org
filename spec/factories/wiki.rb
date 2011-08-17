FactoryGirl.define do
  factory :wiki, :class => WikiPage do
    title "Historique de LinuxFr.org"
    wiki_body "Quelques liens :\n\n* [[[Templeet]]]\n* [[[PierreTramo]]]\n"
    owner_id 1
    message "Draft"
  end
end
