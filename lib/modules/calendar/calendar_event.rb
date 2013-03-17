module RST

  module Calendar

    # A CalendarEvent happens on a given date and has a label. 
    # It's can be used in a Calendar
    # @see Calendar::Calendar
    # @see Calendar::Eventable
    # @example
    #
    #  calendar = Calendar::Calendar.new('my calendar')
    #  event = Calendar::CalendarEvent.new( 'today', "I'm happy" )
    #  calendar << event
    #  calendar.format_events_for(Date.today) 
    #    => "Sun, Mar 17 2013: I'm happy"
    #  calendar << Calendar::CalendarEvent.new('2013-03-18', "Back to work :(")
    #  calendar.list_days('today','4/2013')
    #    => Sun, Mar 17 2013: I'm happy
    #    => Mon, Mar 18 2013: Back to work :(
    #
    class CalendarEvent 

      attr_reader :event_date, :label

      include Eventable
      include CalendarHelper

      # @param [String|Date] _date - Date of the event (only all-day-events are possible yet)
      # @param [String] _label - Events name
      def initialize(_date,_label)
        @label = _label
        schedule! ensure_date(_date)
      end

      # override abstract method for an Eventable
      def event_headline
        self.label.to_s.strip
      end
    end

  end

end 
