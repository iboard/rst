require 'logger'
module RST
  VERSION   = '0.0.0'
  DOCS      = File.expand_path('../assets/docs', __FILE__)
  STOREPATH = File.expand_path('../data/', __FILE__)

  
  # intialize the logger
  def logger
    @logger ||= Logger.new(STDERR)
  end

  # initialize a new logger
  # @param [File|Stream] _output
  def logger!(_output)
    @logger = Logger.new(_output)
  end


end
