task :bundle do
  system "bundle install"
end

task :setup => ["bundle", "db:setup"]
