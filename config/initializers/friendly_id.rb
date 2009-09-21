FriendlyId::DEFAULT_FRIENDLY_ID_OPTIONS = {
  :max_length => 255,
  :method => nil,
  :reserved => %w(new nouveau index show edit modifier),
  :reserved_message => 'ne peut pas être "%s"',
  :cache_column => :cache_slug,
  :scope => nil,
  :strip_diacritics => false,
  :strip_non_ascii => false,
  :use_slug => true
}.freeze
