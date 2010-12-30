# The contrib stylesheets.
#
class Stylesheet < Struct.new(:name, :url)
  BASE_DIR = "stylesheets/contrib"

  def self.all
    Dir.chdir(Rails.root.join('public', BASE_DIR)) do
      Dir['*.css'].map do |css|
        Stylesheet.new(css, "/#{BASE_DIR}/#{css}")
      end
    end
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
    key = LinuxfrOrg::Application::COOKIE_STORE_KEY
    val = cookies[key]
    Dir.chdir Rails.root.join("public") do
      timeout 10 do
        `wkhtmltoimage --crop-h 1024 --cookie '#{key}' '#{val}' '#{url}' #{dst}`
        `mogrify -resize 400x400 #{dst} 2>&1`
      end
    end
    dst
  end

end
