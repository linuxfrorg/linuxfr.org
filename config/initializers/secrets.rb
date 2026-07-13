Rails.application.reloader.to_prepare do
  Push.secret   = ENV.fetch('SECRET_PUSH', Rails.application.credentials.push_secret)
  Devise.pepper = ENV.fetch('SECRET_DEVISE_PEPPER', Rails.application.credentials.devise_pepper)
  Rails.application.config.secret_key_base = ENV.fetch('SECRET_KEY_BASE', Rails.application.credentials.secret_key_base)
end
