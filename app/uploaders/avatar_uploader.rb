# encoding: utf-8

class AvatarUploader < CarrierWave::Uploader::Base

  AVATAR_SIZE = 64
  DEFAULT_AVATAR_URL = "http://#{MY_DOMAIN}/images/default-avatar.png"

  include CarrierWave::MiniMagick
  process :resize_and_pad => [AVATAR_SIZE, AVATAR_SIZE]

  def store_dir
    partition = ("%09d" % model.id).scan(/\d{3}/).reverse.join("/")
    "avatars/#{partition}"
  end

  def filename
    "avatar.#{file.extension}" if original_filename
  end

  def default_url
    DEFAULT_AVATAR_URL + '?' + ENV['RAILS_ASSET_ID']
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

end
