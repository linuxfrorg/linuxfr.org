# encoding: utf-8
class Logo
  Public = Rails.root.join("public")
  Path   = "images/logos"

  def self.image=(img)
    $redis.set "logo", img
  end

  def self.image
    $redis.get "logo"
  end

  def self.all
    logos = []
    Dir.chdir(Public) do
      logos = Dir["#{Path}/*.{png,gif,jpg}"]
    end
    logos.map { |logo| "/#{logo}" }
  end
end
