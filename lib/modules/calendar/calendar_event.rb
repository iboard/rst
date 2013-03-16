module RST

  module Calendar

    # A CalendarEvent happens on a given date and
    # has a label. It's supposed to be appended to a Calendar-object
    # @see Calendar
    class CalendarEvent 

      attr_reader :event_date, :label

      include Eventable
      include CalendarHelper

      # @param [String|Date] _date - Date of the event (only all-day-events are possible yet)
      # @param [String] _label - Events name
      def initialize(_date,_label)
        @event_date = ensure_date(_date)
        @label = _label
      end

      # override abstract method for an Eventable
      def event_headline
        self.label.to_s.strip
      end
    end

  end

end 
