require 'rst'
require 'tempfile'
require 'stringio'

ENV['RST_ENV'] = 'test'
ENV['RST_DATA'] = File.expand_path('../../data',__FILE__)

require 'simplecov'
SimpleCov.start

require File.expand_path('../../lib/load',__FILE__)


def clear_data_path
  system 'rm', '-rf', File.expand_path('../../data/test',__FILE__)
  cal = Persistent::DiskStore.new(CALENDAR_FILE) 
  cal.delete!
rescue
  #noop
end

RSpec.configure do |c|
  clear_data_path
  $last_output = ""
end

def true_run_shell(cmd)
  _rc = ""
  Tempfile.open('cmd') do |f|
    system "#{cmd} > #{f.path} 2>&1"
    f.close
    _rc = File.read(f.path)
  end
  _rc.strip
end

# not in use yet
def run_shell(cmd)
  if ENV['RUN_SHELL'] == 'TRUE'
    true_run_shell(cmd)
  else
    params = cmd.scan( /(\'.*\')|(\S*)/ ).flatten.compact.reject(&:blank?)
    output = ''
    output = capture_stdout_and_stderr  do
      runner = RST::RstCommand.new(params[1..-1])
      puts runner.run.strip
      runner.options={}
    end
    unless $last_output.blank?
      output.gsub!($last_output,'')
    end
    $last_output = output
    output.strip
  end
end

# Thank you Avdi Grimm for this Tapa
def capture_stdout_and_stderr
  old_stdout = STDOUT.clone
  old_stderr = STDERR.clone
  pipe_r, pipe_w = IO.pipe
  pipe_err_r, pipe_err_w = IO.pipe
  pipe_r.sync    = true
  pipe_err_r.sync    = true
  output         = ""
  error          = ""
  STDOUT.flush
  STDERR.flush
  reader = Thread.new do
    begin
      loop do
        output << pipe_r.readpartial(1024)
      end
    rescue EOFError
    end
  end
  err_reader = Thread.new do
    begin
      loop do
        error  << pipe_err_r.readpartial(1024)
      end
    rescue EOFError
    end
  end
  STDOUT.reopen(pipe_w)
  STDERR.reopen(pipe_err_w)
  yield
ensure
  STDOUT.reopen(old_stdout)
  STDERR.reopen(old_stderr)
  pipe_w.close
  pipe_err_w.close
  reader.join
  err_reader.join
  return [output,error].compact.reject(&:blank?).join("\n").strip
end


