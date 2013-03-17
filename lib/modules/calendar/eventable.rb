module RST
  module Calendar

    # Inject Eventable to any Class to make it event-able in a Calendar
    # You have to define a method :event_headline for the class
    # in order to list the event in a Calendar
    # @example
    #
    #   class Birthday < Struct.new(:name,:dob)
    #     include Eventable
    #     def initialize(*args)
    #       super
    #       schedule!(dob)
    #     end
    #
    #     protected
    #     def event_headline
    #       "It's #{name}'s Birthday"
    #     end
    #  end
    #
    # @see RST::Calendar::Calendar
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
      # @return [Eventable] - self
      def schedule!(date)
        @event_date = date.is_a?(Date) ? date : Date.parse(date)
        self
      end

      # used in calendar-output as a short entry
      # @abstract - overwrite in descendants
      # @return [String]
      def event_headline
        self.inspect
      end

    end
  end
end
