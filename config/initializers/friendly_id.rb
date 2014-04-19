# encoding: utf-8
FriendlyId.defaults do |config|
  config.use :finders, :slugged, :reserved, :history
  config.reserved_words = %w(index edit nouveau modifier)
  config.slug_column = :cached_slug
  config.base = :title
end
