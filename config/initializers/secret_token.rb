# encoding: utf-8
secrets = YAML.load_file(Rails.root.join('config/secret.yml'))

Push.secret   = secrets['board_secret']
Devise.pepper = secrets['devise_pepper']
Rails.application.config.secret_token = secrets['rails_secret']
Rails.application.config.img_secret = secrets['images_secret']
