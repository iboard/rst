module RST
  VERSION = '0.0.0'
  DOCS    = File.expand_path('../assets/docs',__FILE__)

  $LOAD_PATH.unshift(File.expand_path('../lib',__FILE__))
  $LOAD_PATH.unshift(File.expand_path('../lib/core_extensions',__FILE__))
  $LOAD_PATH.unshift(File.expand_path('../lib/modules',__FILE__))
  $LOAD_PATH.unshift(File.expand_path('../lib/modules/calendar',__FILE__))

  require 'fixnum'
  require 'calendar'
  require 'eventable'
end
