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
    (self * YEAR).to_f
  end
  alias :year :years

  #:nodoc:
  def months
    (self * MONTH).to_f
  end
  alias :month :months

  #:nodoc:
  def weeks
    (self * WEEK).to_f
  end
  alias :week :weeks

  #:nodoc:
  def days
    (self * DAYS).to_f
  end
  alias :day :days

  #:nodoc:
  def hours
    (self * HOUR).to_f
  end
  alias :hour :hours

  #:nodoc:
  def minutes
    (self * MINUTE).to_f
  end
  alias :minute :minutes

  #:nodoc:
  def seconds
    (self * SECONDS).to_f
  end
  alias :second :seconds

end
