# encoding: utf-8
FactoryGirl.define do
  factory :section do
    title "Articles"
  end

  factory :default_section, :class => Section do
    title "LinuxFr.org"
  end
end
