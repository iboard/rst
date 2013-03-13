module RST
  module Calendar

    # Inject Eventable to any Class to
    # make this class event-able in a Calendar
    module Eventable

      # @return [Date] the date when the event is scheduled
      def event_date
        @event_date
      end
      
      # @return [Boolean] true if the object is scheduled (has an event_date)
      def scheduled?
        !event_date.nil?
      end

      # @param [Date|String] date schedule this object for the given date
      def schedule!(date)
        @event_date = date.is_a?(Date) ? date : Date.parse(date)
        self
      end

      # used in calendar-output as a short entry
      # @return [String]
      def event_headline
        "(untitled event)"
      end

    end
  end
end
