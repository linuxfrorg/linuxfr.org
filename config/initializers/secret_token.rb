# encoding: utf-8
secrets = YAML.load_file(Rails.root.join('config/secret.yml'))

Push.secret       = secrets['board_secret']
Devise.pepper     = secrets['devise_pepper']
Devise.secret_key = secrets['devise_secret']
Rails.application.config.secret_token = secrets['rails_secret']
