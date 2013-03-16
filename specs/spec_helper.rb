require 'tempfile'
require 'stringio'

ENV['RST_ENV'] = 'test'
ENV['RST_DATA'] = File.expand_path('../../data',__FILE__)

require 'simplecov'
SimpleCov.start

require File.expand_path('../../lib/load',__FILE__)


def clear_data_path
  system 'rm', '-rf', File.expand_path('../../data/test',__FILE__)
end

RSpec.configure do |c|
  clear_data_path
end

def run_shell(cmd)
  _rc = ""
  Tempfile.open('cmd') do |f|
    system "#{cmd} > #{f.path} 2>&1"
    f.close
    _rc = File.read(f.path)
  end
  _rc.strip
end

# Thank you Avdi Grimm for this Tappa
def capture_stderr
  old_stdout = STDERR.clone
  pipe_r, pipe_w = IO.pipe
  pipe_r.sync    = true
  output         = ""
  reader = Thread.new do
    begin
      loop do
        output << pipe_r.readpartial(1024)
      end
    rescue EOFError
    end
  end
  STDERR.reopen(pipe_w)
  yield
ensure
  STDERR.reopen(old_stdout)
  pipe_w.close
  reader.join
  return output
end


