# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path

# SVG images
Rails.application.config.assets.precompile += %w[feather-icons/dist/icons/arrow-left.svg]

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )
Rails.application.config.assets.precompile += %w[sorttable.js]
Dir.chdir(Rails.root.join("app/assets/stylesheets")) do
  Rails.application.config.assets.precompile += Dir["contrib/*"].map { |s| s.sub ".scss", ".css" }
  Rails.application.config.assets.precompile += Dir["common/*"].map { |s| s.sub ".scss", ".css" }
  Rails.application.config.assets.precompile += Dir["pygments/*"].map { |s| s.sub ".scss", ".css" }
end
