Factory.define :user do |u|
  u.login 'ptramo'
  u.email { |a| "#{a.login}@dlfp.org" }
  u.password 'I_<3_J2EE'
  u.password_confirmation(&:password)
end
