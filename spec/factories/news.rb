FactoryGirl.define do
  factory :news do
    state 'published'
    title "New release of J2EE"
    wiki_body "Not much to say about it"
    second_part "Nothing here"
    moderator
    section
    author_name "Pierre Tramo"
    author_email "pierre.tramo@dlfp.org"
    after_create do |n|
      n.node.public = true
      n.node.created_at = DateTime.now
      n.node.save
    end
  end
end
