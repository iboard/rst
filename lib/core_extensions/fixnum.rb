# Monkey-patch the numeric class to support n.years,days,... like Rails do
class Numeric

  #:nodoc:
  SECOND  = 1
  #:nodoc:
  SECONDS = SECOND
  #:nodoc:
  MINUTES = 60
  #:nodoc:
  MINUTE  = MINUTES
  #:nodoc:
  HOURS   = MINUTES * 60
  #:nodoc:
  HOUR    = HOURS
  #:nodoc:
  DAYS    = HOUR * 24
  #:nodoc:
  DAY     = DAYS
  #:nodoc:
  WEEKS   = DAY * 7
  #:nodoc:
  WEEK    = WEEKS
  #:nodoc:
  MONTHS  = DAY * 30.5
  #:nodoc:
  MONTH   = MONTHS
  #:nodoc:
  YEAR    = DAY * 365.25
  #:nodoc:
  YEARS   = YEAR

  #:nodoc:
  def years
    (self * YEAR).round
  end
  alias :year :years

  #:nodoc:
  def months
    (self * MONTH).round
  end
  alias :month :months

  #:nodoc:
  def weeks
    (self * WEEK).round
  end
  alias :week :weeks

  #:nodoc:
  def days
    (self * DAYS).round
  end
  alias :day :days

  #:nodoc:
  def hours
    (self * HOUR).round
  end
  alias :hour :hours

  #:nodoc:
  def minutes
    (self * MINUTE).round
  end
  alias :minute :minutes

  #:nodoc:
  def seconds
    (self * SECONDS).round
  end
  alias :second :seconds

end
