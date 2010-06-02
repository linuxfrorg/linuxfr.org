Factory.define :poll do |f|
  f.title "Quelle distribution GNU/Linux ?"
  f.answers_attributes [{:answer => "Debian"}, {:answer => "Ubuntu"}, {:answer => "Fedora"}, {:answer => "Red hat"}, {:answer => "Mandriva"}]
  f.after_create {|p| p.accept! }
end
