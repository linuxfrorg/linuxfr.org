class NewsFigureImageUploader < CarrierWave::Uploader::Base
  NEWS_FIGURE_IMAGE_RATIO = 3
  NEWS_FIGURE_IMAGE_SMALLER_WIDTH = 300

  include CarrierWave::MiniMagick

  storage :file
  process large: [4*NEWS_FIGURE_IMAGE_SMALLER_WIDTH, 4*NEWS_FIGURE_IMAGE_SMALLER_WIDTH/NEWS_FIGURE_IMAGE_RATIO]

  def base_dir
    Rails.root.join("uploads")
  end

  def store_dir
    partition = ("%09d" % model.id).scan(/\d{3}/).reverse.join("/")
    base_dir.join "medias/news/#{partition}"
  end

  def url(*args)
    super.sub(base_dir.to_s, "//#{IMG_DOMAIN}/")
  end

  def srcset
    "#{url(:smaller)} #{NEWS_FIGURE_IMAGE_SMALLER_WIDTH}w,
    #{url(:small)} #{2*NEWS_FIGURE_IMAGE_SMALLER_WIDTH}w,
    #{url(:medium)} #{3*NEWS_FIGURE_IMAGE_SMALLER_WIDTH}w,
    #{url()} #{4*NEWS_FIGURE_IMAGE_SMALLER_WIDTH}w"
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_whitelist
    %w(jpg jpeg gif png)
  end

  # Force file name
  def filename
    "news_figure_image.#{file.extension}" if original_filename
  end

  # Process files as they are uploaded:
  def large(width, height)
    resize_to_limit(width, height)
  end

  version :medium do
    process resize_to_limit(3*NEWS_FIGURE_IMAGE_SMALLER_WIDTH, 3*NEWS_FIGURE_IMAGE_SMALLER_WIDTH/NEWS_FIGURE_IMAGE_RATIO)
  end

  version :small do
    process resize_to_limit(2*NEWS_FIGURE_IMAGE_SMALLER_WIDTH, 2*NEWS_FIGURE_IMAGE_SMALLER_WIDTH/NEWS_FIGURE_IMAGE_RATIO)
  end

  version :smaller do
    process resize_to_limit(NEWS_FIGURE_IMAGE_SMALLER_WIDTH, NEWS_FIGURE_IMAGE_SMALLER_WIDTH/NEWS_FIGURE_IMAGE_RATIO)
  end

end
