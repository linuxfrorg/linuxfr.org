Factory.define :user do |f|
  f.name      "Pierre Tramo"
  f.homesite  "http://java.sun.com/javaee/"
  f.jabber_id "pierre.tramo@dlfp.org"
  f.role      "moule"
  f.association :account
end

Factory.define :anonymous, :class => "user" do |f|
  f.name "Anonyme"
  f.role "inactive"
  f.association :account, :factory => :anonymous_account
end

Factory.define :writer, :class => "user" do |f|
  f.name "Lionel Allorge"
  f.role "writer"
  f.association :account, :factory => :writer_account
end

Factory.define :reviewer, :class => "user" do |f|
  f.name "Pierre Jarillon"
  f.role "reviewer"
  f.association :account, :factory => :reviewer_account
end

Factory.define :moderator, :class => "user" do |f|
  f.name "Florent Zara"
  f.role "moderator"
  f.association :account, :factory => :moderator_account
end

Factory.define :admin, :class => "user" do |f|
  f.name "Benoît Sibaud"
  f.role "admin"
  f.association :account, :factory => :admin_account
end
