require 'tempfile'
require_relative '../rst'
include RST

def run_shell(cmd)
  _rc = ""
  Tempfile.open('cmd') do |f|
    system "#{cmd} > #{f.path}"
    f.close
    _rc = File.read(f.path)
  end
  _rc.strip
end
