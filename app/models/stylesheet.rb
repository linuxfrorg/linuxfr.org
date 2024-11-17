# encoding: utf-8
# The contrib stylesheets.
#
class Stylesheet < Struct.new(:name, :url, :image)
  BASE_DIR = Rails.root.join("app/assets/stylesheets/contrib")

  def self.include?(css)
    return true if css == "mobile"
    css.prepend 'contrib/' unless css.starts_with? 'contrib/'
    Dir["#{BASE_DIR}/#{css.sub 'contrib/', ''}.scss"].any?
  end

  def self.all
    Dir["#{BASE_DIR}/*css"].map do |scss|
      css = File.basename scss, '.scss'
      url = "contrib/#{css}"
      png = "/stylesheets/contrib/#{css}.png"
      Stylesheet.new(css, url, png)
    end.shuffle
  end

  def self.temporary(account, url, &blk)
    original = account.stylesheet
    account.stylesheet = url
    account.save
    yield blk
  ensure
    account.stylesheet = original
    account.save
  end

  def self.capture(url, cookies)
    dst = "tmp/snapshot_#{rand 1000}.png"
    key = COOKIE_STORE_KEY
    val = cookies[key]
    Dir.chdir Rails.root.join("public") do
      timeout 30 do
        cmd = ["phantomjs #{Rails.root}/lib/phantomjs/rasterize.js '#{url}' #{dst} '#{key}' '#{val}'",
               # "wkhtmltoimage --crop-h 1024 --cookie '#{key}' '#{val}' '#{url}' #{dst}",
               "mogrify -resize 400 -extent 400x400 #{dst} 2>&1"].join(" && ")
        system cmd
      end
    end
    dst
  end

end
