FactoryGirl.define do
  factory :application, class: Doorkeeper::Application do
    sequence(:name) { |n| "Application #{n}" }
    redirect_uri 'https://app.com/callback'
    association :owner, factory: :writer_account
  end
end
