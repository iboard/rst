require 'tempfile'

ENV['RST_ENV'] = 'test'

require File.expand_path('../../lib/load',__FILE__)



RSpec.configure do |c|
  path = File.expand_path('../../data/test', __FILE__)
  system 'rm', '-rf', path
end


def run_shell(cmd)
  _rc = ""
  Tempfile.open('cmd') do |f|
    system "#{cmd} > #{f.path}"
    f.close
    _rc = File.read(f.path)
  end
  _rc.strip
end
