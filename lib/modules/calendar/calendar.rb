require 'date'
require 'modules/persistent/persistent'
require 'modules/calendar/calendar_helper'
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

    # Calendar has a name and will be stored in Persistent::DiskStore(CALENDAR_FILE)
    # with it's name as the id. Thus you can save different calendars in
    # the same file. If no name is given 'unnamed' will be the default.
    # @see CALENDAR_FILE
    # @see Persistent::DiskStore
    # @see Calendar::CalendarEvent
    class Calendar

      include Persistent::Persistentable
      include CalendarHelper

      # @group public API

      attr_reader :name, :start_date, :end_date

      # @param [String] _name Name and persistent-id of this calendar.
      # @param [Date|Time|String] _start The date when the calendar starts
      # @param [Date|Time|String] _end   The date when the calendar ends
      # @param [Array] _events initial events
      # @see DEFAULT_CALENDAR_NAME
      def initialize(_name=DEFAULT_CALENDAR_NAME, _start=nil, _end=nil, _events=[])
        @name       = _name
        @start_date = parse_date_param(_start)
        @end_date   = parse_date_param(_end)
        @_events     = _events
      end

      # Return sorted events
      # @return [Array] of Event-objects
      def events
        @_events.sort { |a,b| a.event_date <=> b.event_date }
      end

      # Remove events from calendar by event-ids
      # @param [Array] ids - ids to remove
      def reject_events_by_id!(*ids)
        @_events.reject! do |e|
          ids.include?(e.id)
        end
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
        @_events << add 
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
      def list_days(start_on=start_date,end_on=end_date,show_empty=false,show_ids=false)
        (parse_date_param(start_on)..parse_date_param(end_on)).to_a.map { |_date|
          format_events_for(_date,show_empty,show_ids)
        }.compact
      end


      # All events on the given date
      # @param [Date] date 
      # @return [Array] of [CalendarEvents]
      def events_on(date)
        events.select { |event| event.event_date == date }
      end


      # Dump calendar events
      # @return [String]
      def dump show_ids=false
        events.map { |event|
          if show_ids
            '%-8.8s %-15.15s "%s,%s"' % [ event.id, self.name, event.event_date.strftime('%Y-%m-%d'), event.event_headline ]
          else
            '"%s,%s"' % [ event.event_date.strftime('%Y-%m-%d'), event.event_headline ]
          end
        }.join("\n")
      end

      # Output a calendar for the given range.Including a small
      # monthly calendar on the upper, left and a list of all
      # events within given date-range
      # @param [String|Date] from - Start on date
      # @param [String|Date] to - End on date
      # @param [Boolean] empty - show empty lines (dates without events)
      # @param [Boolean] ids - show ids of each event
      # @return [String]|nil
      def to_text(from,to,empty=false,ids=false)
        unless (_content=list_days(from,to)).empty?
          left_column=build_cal(parse_date_param(from),parse_date_param(to))
          right_column=("EVENTS:\n"+list_days(from,to,empty,ids).join("\n")).split(/\n/)
          render_2col_lines(left_column, right_column)
        end
      end
      # @endgroup

      private
      # @group private API

      # Format a 2 column text-output
      # @example
      #
      #       $ bin/rst -p
      #       work
      #            April 2013        EVENTS:
      #       Su Mo Tu We Th Fr Sa   Wed, Apr 24 2013: RailsConf2013 7h Abflug München + TÜV-Audit
      #           1  2  3  4  5  6   Mon, Apr 29 2013: RailsConf2013
      #        7  8  9 10 11 12 13   Tue, Apr 30 2013: RailsConf2013
      #       14 15 16 17 18 19 20   Wed, May 01 2013: RailsConf2013
      #       21 22 23 24 25 26 27   Thu, May 02 2013: RailsConf2013
      #       28 29 30               Fri, May 03 2013: RailsConf2013
      #                              Sat, May 04 2013: RailsConf2013 Ankunft München
      #                              Mon, May 06 2013: Exam Romy
      #            May 2013
      #       Su Mo Tu We Th Fr Sa
      #       1  2  3  4
      #       5  6  7  8  9 10 11
      #       12 13 14 15 16 17 18
      #       19 20 21 22 23 24 25
      #       26 27 28 29 30 31V
      #
      # @param [Array] left - lines for the left column
      # @param [Array] right - lines for the right column
      # @return [String] - 2 column text-lines
      def render_2col_lines(left,right)
        source = left.count > right.count ? left : right
        rows = []
        source.each_with_index do |_r,idx|
          rows << "%-22.22s %s " % [ left[idx].to_s+"     ", right[idx].to_s ]
        end
        rows.join("\n").gsub(/\s*$/,'')
      end

      # Uses OS' cal-command to format a small calendar for a given month
      # @param [Date|String] from - start on date
      # @param [Date|String] to - end on date
      # @return [Array] of text-lines
      def build_cal from, to
        (from..to).map{ |d| [d.month, d.year ] }.uniq.map { |m,y|
          `cal #{m} #{y}`
        }.join("\n").split(/\n/)
      end

      # Output date and Events on this date in one line
      # @param [Date] _date
      # @param [Boolean] show_empty - do output lines with no events
      # @return [String]
      # @param [Boolean] show_ids - output ids for events
      def format_events_for(_date,show_empty=false,show_ids=false)
        if  (_line=event_headlines_for(_date,show_ids)) != '' || show_empty
          (show_ids ? "%s:\n%s" : "%s: %s") % [_date.strftime(DEFAULT_DATE_FORMAT), _line]
        end
      end

      # Concatenate headlines of all events on this date
      # @param [Date] _date
      # @param [Boolean] _show_ids
      # @return [String]
      def event_headlines_for(_date,_show_ids=false)
        if !_show_ids
          events_on(_date).map(&:event_headline).join(' + ').strip
        else
          events_on(_date).map{|e|
            "%16.16s: %s" % [e.respond_to?(:id) ? e.id : 'n/a' ,e.event_headline]
          }.join("\n").gsub(/\s*$/,'')
        end
      end

      # @endgroup 

    end

  end

end
