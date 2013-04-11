module RST

  # Some useful helpers for dates
  module CalendarHelper

    # You can use 'today' or any format which Date.parse can handle.
    # @example
    #   parse_date_param('1w')
    #   parse_date_param('-41d')
    #   parse_date_param('1week')
    #   parse_date_param('4months')
    #   parse_date_param('-12m')
    #   parse_date_param('today')
    # @param [nil|String|Time|Date] param
    # @return [Date] always returns a Date regardless of the type of input
    def parse_date_param(param)
      if param.is_a?(Date) || param.is_a?(::Time)
        param
      elsif param =~ /today/i || param.nil?
        Date.today 
      elsif param =~ /\d+[a-zA-Z]/i
        get_today_plus(param)
      else 
        Date.parse(param)
      end
    end

    private

    # Get Today + param
    # @example
    #   get_today_plus('1w')
    #   get_today_plus('-41d')
    #   get_today_plus('1week')
    #   get_today_plus('4months')
    #   get_today_plus('-12m')
    # @param [String] param nDWM n=Number Day Weeks Months
    def get_today_plus(param)
      offset = 0
      param.scan(/(\-?)(\d+)([a-z])/i) do |dir,count,unit|
        _count = count.to_i * ( dir.to_s == '-' ?  -1 : 1 )
        offset = case unit[0].downcase
                 when 'd'
                   _count.to_i.days
                 when 'w'
                   _count.to_i.weeks
                 when 'm'
                   _count.to_i.months
                 else
                   raise "Unknown unit #{unit}. Valid units are d,w,m or days,weeks,months"
                 end
      end
      Date.parse( (Time.now + offset).to_s )
    end
  end
end
