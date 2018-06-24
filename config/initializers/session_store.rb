COOKIE_STORE_KEY = 'linuxfr.org_session'.freeze
Rails.application.config.session_store :cookie_store,
  key: COOKIE_STORE_KEY,
  httponly: true,
  secure: true,
  same_site: :strict
