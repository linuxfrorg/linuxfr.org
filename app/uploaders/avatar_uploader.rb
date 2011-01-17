# encoding: utf-8

class AvatarUploader < CarrierWave::Uploader::Base

  AVATAR_SIZE = 64
  DEFAULT_AVATAR_URL = "http://#{MY_DOMAIN}/images/default-avatar.png"

  include CarrierWave::MiniMagick

  storage :file
  process :resize_and_pad => [AVATAR_SIZE, AVATAR_SIZE]

  def store_dir
    partition = ("%09d" % model.id).scan(/\d{3}/).reverse.join("/")
    "avatars/#{partition}"
  end

  def filename
    "avatar.#{file.extension}" if original_filename
  end

  def default_url
    DEFAULT_AVATAR_URL
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

#           :rails_root   => lambda{|u, f| Rails.root },
#           :rails_env    => lambda{|u, f| Rails.env },
#           :class        => lambda{|u, f| u.model.class.name.underscore.pluralize},
#           :id           => lambda{|u, f| u.model.id },
#           :id_partition => lambda{|u, f| ("%09d" % u.model.id).scan(/\d{3}/).join("/")},
#           :attachment   => lambda{|u, f| u.mounted_as.to_s.downcase.pluralize },
#           :style        => lambda{|u, f| u.paperclip_style },
#           :basename     => lambda{|u, f| f.gsub(/#{File.extname(f)}$/, "") },
#           :extension    => lambda{|u, f| File.extname(f).gsub(/^\.+/, "")}

end
