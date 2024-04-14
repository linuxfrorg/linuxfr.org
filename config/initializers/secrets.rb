Rails.application.reloader.to_prepare do
  Push.secret   = Rails.application.secrets.push_secret
  Devise.pepper = Rails.application.secrets.devise_pepper
end
