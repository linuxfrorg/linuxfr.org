Factory.define :news do |f|
  f.state :published
  f.title "New release of J2EE"
  f.body  "Not much to say about it"
  f.second_part "Nothing here"
  f.association :moderator
  f.association :section
  f.author_name "Pierre Tramo"
  f.author_email "pierre.tramo@dlfp.org"
end
