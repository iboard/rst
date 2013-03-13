require 'date'

module RST

  # Calendar-module supports a calendar
  # and later will implement an 'Eventable' submodule.
  # class Calendar is responsible for printing/outputting a calendar
  # Submodule Eventable should be used to make any class an Eventable one.
  module Calendar
  
    # Handle a range from :start_date to :end_date
    class Calendar
    
      attr_reader :start_date, :end_date
    
      # @param [Date|Time|String] _start The date where the calendar starts
      # @param [Date|Time|String] _end   The date where the calendar ends
      def initialize(_start='today',_end='today')
        @start_date = parse_date_param(_start)
        @end_date   = parse_date_param(_end)
      end
  
      # Calculate the span between start and end in secods
      # @return Fixnum
      def span
        ((end_date - start_date)*Fixnum::DAYS).to_f
      end
  
      # list days
      # @return [String]
      def list_days
        (start_date..end_date).to_a.map do |date|
          date.strftime('%a, %b %d %Y')
        end
        .join("\n")
      end
  
      private
  
      # Convert strings to a date
      # @param [Date|Time|String] param
      # @return [Date|Time]
      def parse_date_param(param)
        param ||= Date.today
        return param if param.is_a?(Date) || param.is_a?(::Time)
        return Date.today if param =~ /today/i
        Date.parse(param)
      end
  
    end
  
  end
end
