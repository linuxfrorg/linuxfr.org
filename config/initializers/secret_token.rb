secrets = YAML.load_file(Rails.root.join('config/secret.yml'))

Board.secret  = secrets['board_secret']
Devise.pepper = secrets['devise_pepper']
Rails.application.config.secret_token = secrets['rails_secret']
