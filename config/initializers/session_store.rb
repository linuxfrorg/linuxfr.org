# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key    => '_linuxfr.org_session',
  :secret => '4c65012a410fd83d3dbb161d3f7edd97b4009f9269e0d2cd6a4e6e18030a82d600e9d2ac3ef23d0467b468914b2a3e9974fcd3adce72f4398f870f8923c4ecc2'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
