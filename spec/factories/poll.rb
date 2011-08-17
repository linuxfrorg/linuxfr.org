FactoryGirl.define do
  factory :poll do
    title "Quelle distribution GNU/Linux ?"
    answers_attributes [{:answer => "Debian"}, {:answer => "Ubuntu"}, {:answer => "Fedora"}, {:answer => "Red hat"}, {:answer => "Mandriva"}]
    after_create {|p| p.accept! }
  end
end
