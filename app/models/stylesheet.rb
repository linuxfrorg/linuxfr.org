# The contrib stylesheets.
#
class Stylesheet < Struct.new(:name, :url)
  BASE_DIR = 'stylesheets/contrib'

  def self.all
    Dir.chdir(Rails.root.join('public', BASE_DIR)) do
      Dir['*.css'].map do |css|
        Stylesheet.new(css, "/#{BASE_DIR}/#{css}")
      end
    end
  end

end
