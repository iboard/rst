require 'logger'

# # Ruby Shell Tools Top-level file
module RST
  # Gem-version
  VERSION   = '0.0.0'

  # Path to the docs used by the software
  DOCS      = File.expand_path('../assets/docs', __FILE__)

  # Default DataStore-path. You can overwrite this by
  # defining `ENV[RST_DATA]`
  STOREPATH = File.expand_path('../data/', __FILE__)

  
  # intialize the logger
  # @example Usage
  #   RST.logger.info('This will output to STDERR')
  def logger
    @logger ||= Logger.new(STDERR)
  end

  # initialize a new logger. Necessary from within specs to capture the
  # output for testing.
  # @param [File|Stream] _output
  def logger!(_output)
    @logger = Logger.new(_output)
  end


end
