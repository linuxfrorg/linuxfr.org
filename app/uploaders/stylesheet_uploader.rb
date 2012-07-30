# encoding: utf-8

class StylesheetUploader < CarrierWave::Uploader::Base
  def base_dir
    Rails.root.join("uploads")
  end

  def url
    super.sub(base_dir.to_s, "//#{IMG_DOMAIN}")
  end

  def store_dir
    partition = ("%09d" % model.id).scan(/\d{3}/).reverse.join("/")
    base_dir.join "stylesheets/#{partition}"
  end

  def extension_white_list
    %w(css)
  end
end
