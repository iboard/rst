
require_relative '../spec_helper'

include RST

describe 'Initialize logger' do

  it 'should log to stderr' do
    RST::logger!(STDERR)
    output = capture_stderr do
      RST.logger.fatal('This is no fatal error')
    end
    output.should =~ /FATAL -- : This is no fatal error/
  end

end
