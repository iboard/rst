require 'date'
require 'modules/persistent/persistent'

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
  
    # Methods useful when dealing with Dates
    module CalendarHelper

      # @param [String|Time|Date] param - input whatever you want
      # @return [Date] always returns a Date regardless of the type of input
      def to_date(param)
        return param if param.is_a?(Date) || param.is_a?(::Time)
        return Date.today if param =~ /today/i
        Date.parse(param)
      end
    end

    # Handle a range from :start_date to :end_date. Store it as :name
    class Calendar

      include Persistent::Persistentable
      include CalendarHelper

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


      # Setter for from-date
      # @param [Date|String] from - Starting date
      def from=(from)
        @start_date = parse_date_param(from)
      end

      # Setter for to-date
      # @param [Date|String] to - Starting date
      def to=(to)
        @end_date = parse_date_param(to)
      end

      # Override Persistentable's id-method
      # @return [String] - the calendar-name is it's id
      def id
        @name || super
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
      def list_days(start_on=start_date,end_on=end_date)
        start_on = parse_date_param(start_on)
        end_on   = parse_date_param(end_date)
        (start_on..end_on).to_a.map do |_date|
          [_date.strftime('%a, %b %d %Y'), events_on(_date)].compact.join(": ")
        end
        .join("\n")
      end
      
  
      private
      # List Event-headlines for a given date
      def events_on(date)
        events.select { |event| event.event_date == date }.map(&:event_headline).join(' + ')
      end
      
      # Convert strings to a date
      # @param [Date|Time|String] param
      # @return [Date|Time]
      def parse_date_param(param)
        param ||= Date.today
        to_date(param)
      end
  
    end

  end

end
