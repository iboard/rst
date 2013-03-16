unless defined? LIB_LOADED

  # prevent from double loading
  LIB_LOADED = true

  # Used with strftime(DEFAULT_DATE_FORMAT) when printing dates
  DEFAULT_DATE_FORMAT = '%a, %b %d %Y'

  # Filename for the calendar-store
  CALENDAR_FILE = 'calendars.data'

  require File.expand_path('../../rst',__FILE__)

  # Load all necessary files
  $LOAD_PATH.unshift(File.expand_path('..',__FILE__))

  $LOAD_PATH.unshift(File.expand_path('../core_extensions',__FILE__))
  require 'numeric'

  $LOAD_PATH.unshift(File.expand_path('../errors',__FILE__))
  require 'store_errors'

  $LOAD_PATH.unshift(File.expand_path('../modules/calendar',__FILE__))
  require 'calendar'
  require 'eventable'
  require 'calendar_event'

  $LOAD_PATH.unshift(File.expand_path('../modules/persistent',__FILE__))
  require 'persistent'
  require 'store'
  require 'memory_store'
  require 'disk_store'

  
  include RST
end

