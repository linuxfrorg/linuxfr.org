Factory.define :section do |f|
  f.state 'published'
  f.title "Articles"
  f.image { File.new(Rails.root.join("public/images/sections/1.png")) }
  f.after_build { |s| s.stub(:save_attached_files).and_return(true) }
end
