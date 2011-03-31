# encoding: utf-8

class AvatarUploader < CarrierWave::Uploader::Base

  AVATAR_SIZE = 64
  DEFAULT_AVATAR_URL = "http://#{MY_DOMAIN}/images/default-avatar_1.gif"

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
    DEFAULT_AVATAR_URL + '?' + ENV['RAILS_ASSET_ID'].to_s
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  def resize_and_pad(width, height, background=:transparent, gravity='Center')
    super(width, height, background, gravity) do |img|
      return img unless img["format"] == "GIF"
      nb_frames = img["%n"].to_i
      if nb_frames > 1
        img.run_command("convert", img.path + "[0]", img.path)
      end
      img
    end
  end

end
