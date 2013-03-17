require 'date'
require 'modules/persistent/persistent'

module RST

  # Calendar-module provides the Calendar-class which is supposed to hold
  # 'Eventable'-objects. Where Eventable is a module you can include to any class.
  # A Calendar has a start- and ending-date, and a name. The name is used
  # to store the calendar in a store using this name as the id.
  #
  # @see Persistent::DiskStore
  #
  # @example
  #
  #     class Person
  #       include Eventable
  #
  #       def initialize name, dob
  #         @name = name
  #         schedule! dob
  #       end
  #
  #       # override abstract method to format the output
  #       def event_headline
  #         '#{name}\'s Birthday'
  #       end
  #     end
  #
  #     birthdays = Calendar.new('birthdays')
  #     birthdays << Person.new('Andi',   '31. Aug. 1964')
  #     birthdays << Person.new('Heidi',  '28. Aug. 1969')
  #     birthdays << Person.new('Julian', '17. Feb. 1995')
  #     birthdays << Person.new('Tina',   '22. May. 1997')
  #
  #     puts birthdays.list_days('31.8.1963','today') 
  #     # => Mon, Aug 31 1964: Andi's Birthday
  #     # => Thu, Aug 28 1969: Heidi's Birthday
  #     # => Fri, Feb 17 1995: Julian's Birthday
  #     # => Thu, May 22 1997: Tina's Birthday
  #
  module Calendar
  
    # Some helper-methods useful when dealing with dates
    module CalendarHelper

      # You can use 'today' or any format which Date.parse can handle.
      # @param [nil|String|Time|Date] param
      # @return [Date] always returns a Date regardless of the type of input
      def ensure_date(param)
        if param.is_a?(Date) || param.is_a?(::Time)
          param
        elsif param =~ /today/i || param.nil?
          Date.today 
        else
          Date.parse(param)
        end
      end
    end

    # Calendar has a name and will be stored in Persistent::DiskStore(CALENDAR_FILE)
    # with it's name as the id. Thus you can save different calendars in
    # the same file. If no name is given 'unnamed' will be the default.
    # @see CALENDAR_FILE
    # @see Persistent::DiskStore
    # @see Calendar::CalendarEvent
    class Calendar

      include Persistent::Persistentable
      include CalendarHelper

      attr_reader :name, :start_date, :end_date, :events
   
      # @param [String] _name Name and persistent-id of this calendar.
      # @param [Date|Time|String] _start The date when the calendar starts
      # @param [Date|Time|String] _end   The date when the calendar ends
      # @see DEFAULT_CALENDAR_NAME
      def initialize(_name=DEFAULT_CALENDAR_NAME, _start=nil, _end=nil, _events=[])
        @name       = _name
        @start_date = parse_date_param(_start)
        @end_date   = parse_date_param(_end)
        @events     = _events
      end


      # Setter for from_date
      # @param [Date|String] _from - new starting date
      def from=(_from)
        @start_date = parse_date_param(_from)
      end

      # Setter for to-date
      # @param [Date|String] _to - new ending date
      def to=(_to)
        @end_date = parse_date_param(_to)
      end

      # Override Persistentable's id-method
      # @see Persistent::Persistentable
      # @return [String] - the calendar-name is it's id
      def id
        @name || super
      end

      # Add Eventables to the calendar
      # @param [Eventable] add - the Object to add
      def <<(add)
        events << add 
      end
  
      # Calculate the span between start and end in seconds
      # @return [Float]
      def span
        ((end_date - start_date)*Numeric::DAYS).to_f
      end
  
      # Array of strings for each day with events on it.
      #
      # @example
      #     Mon, Aug 31 1964: Birthday Andreas Altendorfer
      #
      # @param [String|Date] start_on - output begins on this day
      # @param [String|Date] end_on   - output ends on this day
      # @param [Boolean] show_empty   - output days with no events
      # @return [Array] of Strings DATE: EVENT + EVENT + ....
      def list_days(start_on=start_date,end_on=end_date,show_empty=false)
        (parse_date_param(start_on)..parse_date_param(end_on)).to_a.map { |_date|
          format_events_for(_date,show_empty)
        }.compact
      end
      
  
      private
      # All events on the given date
      # @param [Date] date 
      # @return [Array] of [CalendarEvents]
      def events_on(date)
        events.select { |event| event.event_date == date }
      end
      
      # Convert strings to a date
      # @param [Date|Time|String] param - default is 'today'
      # @return [Date|Time]
      def parse_date_param(param=Date.today)
        ensure_date(param)
      end

      # Output date and Events on this date in one line
      # @param [Date] _date
      # @param [Boolean] show_empty - do output lines with no events
      # @return [String]
      def format_events_for(_date,show_empty=false)
        if show_empty || (_line=event_headlines_for(_date)) != ''
          "%s: %s" % [_date.strftime(DEFAULT_DATE_FORMAT), _line]
        end
      end

      # Concatenate headlines of all events on this date
      # @param [Date] _date
      # @return [String]
      def event_headlines_for(_date)
        events_on(_date).map(&:event_headline).join(' + ').strip
      end
  
    end

  end

end
