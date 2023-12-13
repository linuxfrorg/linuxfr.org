# encoding: UTF-8
date_formats = {
  date:      '%d/%m/%y',
  posted:    ->(t) {I18n.l(t, format: :posted)},
  norloge:   '%H:%M:%S',
  norloge2:  '%Y-%m-%d %H:%M:%S',
  timestamp: '%Y%m%d%H%M%S'
}

Time::DATE_FORMATS.update(date_formats)
Date::DATE_FORMATS.update(date_formats)
