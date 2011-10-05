# encoding: UTF-8
#
# == Schema Information
#
# Table name: users
#
#  id            :integer(4)      not null, primary key
#  name          :string(32)
#  homesite      :string(100)
#  jabber_id     :string(32)
#  cached_slug   :string(32)
#  created_at    :datetime
#  updated_at    :datetime
#  gravatar_hash :string(32)
#  avatar        :string(255)
#  signature     :string(255)
#

FactoryGirl.define do
  factory :user do
    name      "Pierre Tramo"
    homesite  "http://java.sun.com/javaee/"
    jabber_id "pierre.tramo@dlfp.org"
    association :account, :factory => :normal_account
  end

  factory :anonymous, :class => User do
    name "Anonyme"
    association :account, :factory => :anonymous_account
  end

  factory :writer, :class => User do
    name "Lionel Allorge"
    association :account, :factory => :writer_account
  end

  factory :reviewer, :class => User do
    name "Pierre Jarillon"
    association :account, :factory => :reviewer_account
  end

  factory :moderator, :class => User do
    name "Florent Zara"
    association :account, :factory => :moderator_account
  end

  factory :admin, :class => User do
    name "Benoît Sibaud"
    association :account, :factory => :admin_account
  end
end
