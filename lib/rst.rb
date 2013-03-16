require 'optparse'
require 'ostruct'

# # Ruby Shell Tools main namespace RST
#
# @author Tue Mar 12 19:24:52 2013 <andreas@altendorfer.at>
# @see https://github.com/iboard/rst
# @see http://altendorfer.at
module RST

  # Run commands given as ARGV with options
  class RstCommand

    attr_reader :options # the hash stores options parsed with option_parser
    attr_reader :command # the first argument of ARGV is the command

    # Initialize the Command-runner with arguments
    # normally given on the command-line. See --help
    def initialize(args)
      parse_options(args)
    end

    # Call 'run_options' and 'run_arguments', reject empty returns and join
    # output with CR
    # @return [String]
    def run
      [run_options, run_arguments].compact.reject{|l| l.strip == '' }.join("\n")
    end

    private

    # Interpret options from ARGV using Option Parser
    def parse_options(args)
      @options = { name: 'unnamed', from: 'today', to: 'today', show_empty: false }
      OptionParser.new do |opts|

        opts.banner = 'Usage: rst [COMMAND [COMMAND ....]] [options] [FILES..]'

        opts.separator "\nOptions:"

        opts.on('-v', '--[no-]verbose', 'Run verbosely') do |v|
          @options[:verbose] = v
        end

        opts.on('--examples', 'Show some usage examples') do |x|
          @options[:examples] = x
        end

        opts.on('-h', '--help', 'Print help') do |h|
          puts opts
        end

        opts.on('-f', '--from DATE', String, 'Set from-date') do |from|
          @options[:from] = from
        end

        opts.on('-t', '--to DATE', String, 'Set to-date') do |to|
          @options[:to] = to
        end

        opts.on('-n', '--name NAME', String, 'Use this name for the command') do |name|
          @options[:name] = name
        end

        opts.on('-e', '--new-event DATE,STRING', Array, 'Add an event') do |date,name|
          @options[:new_event] = {date: date, label: name}
        end
         
        opts.on('--list-calendars', 'List available calendars') do
          @options[:list_calendars] = true
        end
         
        opts.on('--delete-calendar CALENDARNAME', String, 'Delete an calendar and all it\'s entries!') do |name|
          @options[:delete_calendar] = name
        end
         
        opts.on('--[no-]empty', 'Show empty entries') do |show|
          @options[:show_empty] = show
        end

        opts.separator 'Commands:'

        opts.separator <<-EOT
          nil .......... no command. Interpret options only (useful in combination with -v)
          ls ........... list directory and files
          cal[endar] ... print a calendar --from --to
        EOT
        .gsub(/^\s+/,'    ')

        opts.separator "\n    use --example for a more detailed list of commands."



      end
      .parse!(args)
    rescue => e
      puts "#{e.class} => #{e.message}"
      puts "Try #{File.basename($0)} --help"
    end

    # Run previously parsed options
    # @return [String]
    def run_options
      options.map { |k,_v| run_option(k) }.compact.join("\n")
    end

    # The first argument of ARGV is the 'command'
    # run known commands, print out unknwon commands with a hint to --help
    # @return [String]
    def run_arguments
      case @command=ARGV.shift
      when nil, 'nil', 'null'
        ''
      when 'ls'              
        directory_listing(ARGV.empty? ? ['*'] : ARGV)
      when 'cal', 'calendar' 
        print_calendar
      else
        "unknown command '#{cmd.inspect}' - try --help"
      end
    end

    # Output the previous interpreted and parsed arguments
    def print_arguments
      puts "Binary : #{$0}"
      puts "Command: #{command}"
      puts "Options: #{options.map(&:inspect).join(', ')}"
      puts "Files  : #{ARGV.any? ? ARGV[1..-1].join(', ') : ''}"
    end

    # Do a Dir for each file-mask given
    # @param [Array] files
    # @return [String] - tab-delimited files
    def directory_listing(files)
      files.map do |f|
        Dir[f].join("\t")
      end
      .uniq.join("\t")
    end

    # Output one line per day between start and end-date
    def print_calendar
      store = Persistent::DiskStore.new(CALENDAR_FILE)
      cal = store.find(options[:name]) || Calendar::Calendar.new(options[:name], options[:from], options[:to])
      cal.list_days(options[:from], options[:to],options[:show_empty]).compact.join("\n")
    end

    # Add an event to the calendar 'name'
    def add_event
      date = options[:new_event].fetch(:date) { Date.today.strftime('%Y-%m-%d') }
      label = options[:new_event].fetch(:label) { 'unnamed event' }
      calendar_name = options.fetch(:name) { 'calendar' }
      event=Calendar::CalendarEvent.new( date, label )
      store = Persistent::DiskStore.new(CALENDAR_FILE)
      calendar = store.find(calendar_name) || Calendar::Calendar.new(calendar_name)

      calendar << event
      store << calendar
      event
    end

    # remove a calendar from calendar-file named in options[:delete_calendar]
    def delete_calendar
      store = Persistent::DiskStore.new(CALENDAR_FILE)
      store -= OpenStruct.new(id: options[:delete_calendar])
      nil
    end

    # List available calendars
    def list_calendars
      store = Persistent::DiskStore.new(CALENDAR_FILE)
      store.all.map { |calendar|
        cnt = calendar.events.count
        "%-20.20s: %d %s" % [calendar.id, cnt > 0 ? cnt : 'no', cnt > 1 ? 'entries' : 'entry']
      }
    end

    # Execute a single option
    # @see [parse_options], [run_options] 
    # @param String option (examples, verbose, new_event,...)
    def run_option(option)
      case option.to_s
      when 'examples'
        File.read(File.join(DOCS,'examples.md')).strip
      when 'verbose'
        print_arguments
      when 'new_event'
        new_event = add_event
        "Added: %s: %s" % [new_event.event_date.strftime(DEFAULT_DATE_FORMAT), new_event.event_headline.strip]
      when 'list_calendars'
        list_calendars
      when 'delete_calendar'
        delete_calendar
      else
        nil #noop ignore unknown options likely it's a param for an argument
      end
    end
  end

end
