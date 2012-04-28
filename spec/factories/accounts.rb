# encoding: utf-8
# == Schema Information
#
# Table name: accounts
#
#  id                   :integer(4)      not null, primary key
#  user_id              :integer(4)
#  login                :string(40)      not null
#  role                 :string(10)      default("visitor"), not null
#  karma                :integer(4)      default(20), not null
#  nb_votes             :integer(4)      default(0), not null
#  stylesheet           :string(255)
#  email                :string(255)     default(""), not null
#  encrypted_password   :string(128)     default(""), not null
#  confirmation_token   :string(255)
#  confirmed_at         :datetime
#  confirmation_sent_at :datetime
#  reset_password_token :string(255)
#  remember_token       :string(255)
#  remember_created_at  :datetime
#  sign_in_count        :integer(4)      default(0)
#  current_sign_in_at   :datetime
#  last_sign_in_at      :datetime
#  current_sign_in_ip   :string(255)
#  last_sign_in_ip      :string(255)
#  created_at           :datetime
#  updated_at           :datetime
#  preferences          :integer(4)      default(0), not null
#

FactoryGirl.define do
  factory :account do
    email { "#{login}@dlfp.org" }
    after_build { |a| a.skip_confirmation! }

    factory :normal_account do
      login "ptramo"
      role  "visitor"
      after_create do |a|
        a.password = a.password_confirmation = 'I<3J2EE'
        a.save
      end
    end

    factory :anonymous_account do
      login "anonyme"
      role  "inactive"
    end

    factory :writer_account do
      login "LionelAllorge"
      role  "visitor"
    end

    factory :reviewer_account do
      login "jarillon"
      role  "reviewer"
    end

    factory :moderator_account do
      login "floxy"
      role  "moderator"
    end

    factory :admin_account do
      login "oumph"
      role  "admin"
    end
  end
end
