date_formats = {
  :posted    => '%d/%m/%Y à %H:%M',
  :norloge   => '%H:%M:%S',
  :timestamp => '%Y%m%d%H%M%S'
}

ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS.update(date_formats)
ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.update(date_formats)
# DateTime uses Time's DATE_FORMATS, so there's nothing to update for it.
