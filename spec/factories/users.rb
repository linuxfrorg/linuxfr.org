# encoding: UTF-8
Factory.define :user do |f|
  f.name      "Pierre Tramo"
  f.homesite  "http://java.sun.com/javaee/"
  f.jabber_id "pierre.tramo@dlfp.org"
  f.association :account
end

Factory.define :anonymous, :class => "user" do |f|
  f.name "Anonyme"
  f.association :account, :factory => :anonymous_account
end

Factory.define :writer, :class => "user" do |f|
  f.name "Lionel Allorge"
  f.association :account, :factory => :writer_account
end

Factory.define :reviewer, :class => "user" do |f|
  f.name "Pierre Jarillon"
  f.association :account, :factory => :reviewer_account
end

Factory.define :moderator, :class => "user" do |f|
  f.name "Florent Zara"
  f.association :account, :factory => :moderator_account
end

Factory.define :admin, :class => "user" do |f|
  f.name "Benoît Sibaud"
  f.association :account, :factory => :admin_account
end
