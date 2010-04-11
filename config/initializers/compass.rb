require 'compass'
Compass.add_project_configuration(File.join(Rails.root, "config", "compass.rb"))
Compass.configure_sass_plugin!
Compass.handle_configuration_change!
