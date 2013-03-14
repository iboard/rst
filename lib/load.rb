unless defined? LIB_LOADED

  # prevent double loading
  LIB_LOADED = true
  require File.expand_path('../../rst',__FILE__)

  # Load all necessary files
  $LOAD_PATH.unshift(File.expand_path('..',__FILE__))

  $LOAD_PATH.unshift(File.expand_path('../core_extensions',__FILE__))
  require 'fixnum'

  $LOAD_PATH.unshift(File.expand_path('../errors',__FILE__))
  require 'store_errors'

  $LOAD_PATH.unshift(File.expand_path('../modules/calendar',__FILE__))
  require 'calendar'
  require 'eventable'

  $LOAD_PATH.unshift(File.expand_path('../modules/persistent',__FILE__))
  require 'persistent'
  require 'store'
  require 'memory_store'
  require 'disk_store'

  
  include RST
end

