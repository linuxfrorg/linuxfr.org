Factory.define :user do |f|
  f.name      "Pierre Tramo"
  f.homesite  "http://java.sun.com/javaee/"
  f.jabber_id "pierre.tramo@dlfp.org"
  f.role      "moule"
end

Factory.define :anonymous, :class => "user" do |f|
  f.name "Anonyme"
  f.role "inactive"
end

Factory.define :writer, :class => "user" do |f|
  f.name "Lionel Allorge"
  f.role "writer"
end

Factory.define :reviewer, :class => "user" do |f|
  f.name "Pierre Jarillon"
  f.role "reviewer"
end

Factory.define :moderator, :class => "user" do |f|
  f.name "Florent Zara"
  f.role "moderator"
end

Factory.define :admin, :class => "user" do |f|
  f.name "Benoît Sibaud"
  f.role "admin"
end
