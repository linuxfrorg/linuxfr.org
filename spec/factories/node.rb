Factory.define :node do |f|
  f.association :content, :factory => :diary
  f.user_id { |n| n.content.owner_id }
end
