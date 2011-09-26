FactoryGirl.define do
  factory :account do
    email { "#{login}@dlfp.org" }
    after_build { |a| a.skip_confirmation! }

    factory :normal_account do
      login "ptramo"
      role  "moule"
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
      role  "moule"
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
