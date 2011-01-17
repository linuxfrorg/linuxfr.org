CarrierWave.configure do |config|
  config.cache_dir = "tmp/uploads"
  config.storage = :file
end
