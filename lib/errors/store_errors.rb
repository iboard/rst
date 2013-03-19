module RST

  # Exception thrown when an abstract method is called
  class AbstractMethodCallError < NotImplementedError

    def initialize message='Please define '
      _message = [ message, format_backtrace(caller_locations(2,1)), 'Called from:']
      (3..24).to_a.each do |n|
        _message << format_backtrace(caller_locations(n,1))
      end
      super(_message.join(" => "))
    end

    private

    # Output the filename and line of a backtrace-step
    # @param [Array] l - one caller_location-line
    # @return [String]
    def format_backtrace(l)
      "%s in %s:%d" % [l[0].label,File.basename(l[0].path),l[0].lineno]
    end

  end

end
