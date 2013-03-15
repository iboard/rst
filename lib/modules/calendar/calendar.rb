require 'date'

module RST

  # Calendar-module provides the Calendar-class which is supposed to hold
  # 'Eventable'-objects. Where Eventable is a module you can include to any class.
  # A Calendar has a start- and ending-date, and a name. The name is used
  # to store the calendar in a store using this name.
  #
  # @example
  #
  #     ATTENTION - This is a draft and not working yet (this way)
  #
  #     class Person < Struct.new(:name,:dob)
  #       include Eventable
  #       def event_headline
  #         '#{name}\'s Birthday'
  #       end
  #     end
  #
  #     birthdays = Calendar.new('birthdays', '1964-01-01','today')
  #     birthdays << Person.new('Andi',   '31. Aug. 1964')
  #     birthdays << Person.new('Heidi',  '28. Aug. 1969')
  #     birthdays << Person.new('Julian', '17. Feb. 1995')
  #     birthdays << Person.new('Tina',   '22. May. 1997')
  #
  #     pus birthdays.list_days =>
  #       Mon, Aug 31 1964: Andi's Birthday
  #       ...
  #       Thu, Aug 28 1969: Heidi's Birthday
  #       ...
  #       Fri, Feb 17 1995: Julian's Birthday
  #       ...
  #       Thu, May 22 1997: Tina's Birthday
  #       ...
  #       Fri, Mar 15 2013:
  #
  #
  module Calendar
  
    # Handle a range from :start_date to :end_date. Store it as :name
    class Calendar

      attr_reader :name, :start_date, :end_date, :events
    
      # @param [String] _name Name of this calendar. Also used when storing
      # @param [Date|Time|String] _start The date where the calendar starts
      # @param [Date|Time|String] _end   The date where the calendar ends
      def initialize(_name='unnamed', _start='today',_end='today',_events=[])
        @name       = _name
        @start_date = parse_date_param(_start)
        @end_date   = parse_date_param(_end)
        @events     = _events
      end

      # Add Eventables to the calendar
      def <<(add)
        events << add 
      end
  
      # Calculate the span between start and end in seconds
      # @return Fixnum
      def span
        ((end_date - start_date)*Fixnum::DAYS).to_f
      end
  
      # list days
      # @return [String]
      def list_days
        (start_date..end_date).to_a.map do |date|
          [date.strftime('%a, %b %d %Y'), events_on(date)].compact.join(": ")
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

      # List Event-headlines for a given date
      def events_on(date)
        events.select { |event| event.event_date == date }.map(&:event_headline).join(' + ')
      end
  
    end
  
  end
end
