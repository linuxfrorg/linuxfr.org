Factory.define :section do |f|
  f.title "Articles"
end

Factory.define :default_section, :class => "section" do |f|
  f.title "LinuxFr.org"
end
