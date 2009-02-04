# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_linuxfr.org_session',
  :secret      => '042c640cb2b4542194e4a5c613aad9104bb0a6bdd6dbf3ebed6cb3e440b7deb09544caf2189a192eb139f896f7f978aed266c3f6a335ef00433069e1a391858d'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
