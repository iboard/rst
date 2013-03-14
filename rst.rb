require 'logger'
module RST
  VERSION   = '0.0.0'
  DOCS      = File.expand_path('../assets/docs', __FILE__)
  STOREPATH = File.expand_path('../data/', __FILE__)

  
  def logger
    @logger ||= Logger.new(STDOUT)
  end


end
