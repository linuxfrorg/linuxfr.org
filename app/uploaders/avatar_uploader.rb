# encoding: utf-8

class AvatarUploader < CarrierWave::Uploader::Base

  AVATAR_SIZE = 64
  DEFAULT_AVATAR_URL = "//#{MY_DOMAIN}/images/default-avatar.png"

  include CarrierWave::MiniMagick
  process :resize_and_pad => [AVATAR_SIZE, AVATAR_SIZE]

  def base_dir
    Rails.root.join("uploads")
  end

  def url
    super.sub(base_dir.to_s, "//#{IMG_DOMAIN}")
  end

  def store_dir
    partition = ("%09d" % model.id).scan(/\d{3}/).reverse.join("/")
    base_dir.join "avatars/#{partition}"
  end

  def filename
    "avatar.#{file.extension}" if original_filename
  end

  def extension_white_list
    %w(jpg jpeg gif png svg)
  end

  def resize_and_pad(width, height, background=:transparent, gravity='Center')
    super(width, height, background, gravity) do |img|
      if img["format"] == "GIF"
        nb_frames = img["%n"].to_i
        if nb_frames > 1
          img.run_command("convert", img.path + "[0]", img.path)
        end
      end
      yield img if block_given?
      img
    end
  end

end
