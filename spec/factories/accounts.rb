Factory.define :account do |f|
  f.login "ptramo"
  f.email "ptramo@dlfp.org"
  f.after_build { |a| a.skip_confirmation! }
end

Factory.define :anonymous_account, :class => 'account' do |f|
  f.login "anonyme"
  f.email "anonyme@dlfp.org"
  f.after_build { |a| a.skip_confirmation! }
end

Factory.define :writer_account, :class => 'account' do |f|
  f.login "LionelAllorge"
  f.email "writer@dlfp.org"
  f.after_build { |a| a.skip_confirmation! }
end

Factory.define :reviewer_account, :class => 'account' do |f|
  f.login "jarillon"
  f.email "reviewer@dlfp.org"
  f.after_build { |a| a.skip_confirmation! }
end

Factory.define :moderator_account, :class => 'account' do |f|
  f.login "floxy"
  f.email "moderator@dlfp.org"
  f.after_build { |a| a.skip_confirmation! }
end

Factory.define :admin_account, :class => 'account' do |f|
  f.login "oumph"
  f.email "admin@dlfp.org"
  f.after_build { |a| a.skip_confirmation! }
end
