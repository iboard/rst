require 'optparse'
require 'ostruct'
require_relative './modules/persistent/persistent'

# # Ruby Shell Tools main namespace RST
#
# By now only two commands/features are available:
#
#  * **ls** - List files from the filesystem (OS-like ls)
#  * **cal[endar]** - Stores and lists events in one calendar-file, 
#    separated in different named calendars 
#
# See [EXAMPLES.md](./file.examples.html) for detailed instruction.
#
#
# @author Andi Altendorfer <andreas@altendorfer.at>
# @see https://github.com/iboard/rst
# @see http://altendorfer.at
module RST

  # Interprets and runs options and commands.
  # @example
  #   runner = RstCommand.new(ARGV)
  #   puts runner.run
  # See [EXAMPLES.md](../file.examples.html)
  class RstCommand

    # Default options are always present, even if the user will not provide them.
    # They can be overwritten, though. 
    # @see #parse_options
    DEFAULT_OPTIONS = { name: 'unnamed', from: 'today', to: 'today', show_empty: false }

    # @group PUBLIC INTERFACE

    # the hash stores options parsed in mehtod parse_options.
    # @see #parse_options
    attr_reader :options

    # the first argument of ARGV is the command. It's extracted in run_command
    # @see #run_command
    attr_reader :command

    # Initialize the Command-runner with arguments and parse them.
    def initialize(args)
      load_defaults
      parse_options(args)
      _command = args.shift
      @command = _command if _command
      @files = args
    end

    # Call 'run_options' and 'run_command', reject empty returns and join
    #   output with CR
    # @return [String]
    def run
      [run_options, run_command].compact.reject{|l| l.strip == '' }.join("\n")
    end

    private

    # @group PREPARE OPTIONS AND COMMAND

    # Interpret options from ARGV using OptionParser. No action here. The parsed
    #   options get stored in '@options' and then will be used in run_options.
    # @see #options
    # @see #DEFAULT_OPTIONS
    # @see #run_options
    # @see #run_option
    def parse_options(args)
      OptionParser.new do |opts|
        opts.banner = 'Usage: rst [COMMAND] [options] [FILES..]'

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

        opts.on('--save-defaults', 'Save given params as defaults') do |v|
          @options[:save_defaults] = v
        end

        opts.on('--list-defaults', 'list saved defaults') do |v|
          @options[:list_defaults] = v
        end

        opts.on('--clear-defaults', 'delete previously saved defaults') do |v|
          @options[:clear_defaults] = v
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

    # Iterate over all given options and call run_option for each
    # @see #run_option
    # @return [String]
    def run_options
      options.map { |k,_v| run_option(k) }.compact.join("\n")
    end

    # Run the 'command', the first argument of ARGV.
    # If a command is not known/invalid print out a hint to --help
    # Known commands are:
    # @see #directory_listing
    # @see #print_calendar
    # @see #command
    # @return [String]
    def run_command
      case @command
      when nil, 'nil', 'null'
        ''
      when 'ls'
        @files << '*' if @files.empty?
        directory_listing( @files )
      when 'cal', 'calendar'
        print_calendar
      else
        "unknown command '#{cmd.inspect}' - try --help"
      end
    end


    # @group EXECUTE COMMANDS

    # Do a Dir for each file-mask given.
    # Duplicated files are stripped.
    # @example
    #   rst ls lib/*rb
    # @param [Array] files - a list of files/wildcards
    # @return [String] - tab-delimited files found
    def directory_listing(files)
      files.map { |f| Dir[f].join("\t") }.uniq.join("\t")
    end

    # Output one line per day between start and end-date
    # Start- and end-date are given with options --from, and --to
    # Option --empty will output dates without events too.
    # default is --no-empty which will suppress those lines in output
    # @example 
    #   rst cal --from 1.1.1990 --to today --name Birthdays
    # @return [Array] - one string Date: Event + Event + ... for each day.
    def print_calendar
      cal = find_calendar( Persistent::DiskStore.new(CALENDAR_FILE) )
      cal.list_days(options[:from], options[:to], options[:show_empty]).compact.join("\n")
    end

    # @group EXECUTE ACTION FROM OPTIONS

    # Execute a single option
    # @see #parse_options
    # @see #run_options
    # @param [String] option (examples, verbose, new_event,...)
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
      when 'save_defaults'
        save_defaults
      when 'list_defaults'
        list_defaults
      when 'clear_defaults'
        clear_defaults
      else
        nil #noop ignore unknown options likely it's a param for an argument
      end
    end

    # Add an event to the calendar.
    # @example
    #   --add-event DATE,LABEL
    # @return [CalendarEvent] - the just created event
    def add_event
      event_environment do |ee|
        ee[:calendar] << ee[:event]
        ee[:store] << ee[:calendar]
        ee[:event]
      end
    end

    # remove a calendar from calendar-file named in options[:delete_calendar]
    # @example
    #   --delete-calendar CALENDARNAME
    def delete_calendar
      store = Persistent::DiskStore.new(CALENDAR_FILE)
      store -= OpenStruct.new(id: options[:delete_calendar])
      nil
    end

    # List available calendars and count events of each one.
    # @return [Array] One line/String for each calendar
    def list_calendars
      store = Persistent::DiskStore.new(CALENDAR_FILE)
      store.all.map { |calendar|
        cnt = calendar.events.count
        "%-20.20s: %d %s" % [calendar.id, cnt > 0 ? cnt : 'no', cnt > 1 ? 'entries' : 'entry']
      }
    end

    # Output the previous interpreted and parsed arguments
    # Called when --verbose is given as an option
    # @example
    #   rst --verbose
    def print_arguments
      puts "Binary : #{$0}"
      puts "Command: #{command}"
      puts "Options: #{options.map(&:inspect).join(', ')}"
      puts "Files  : #{@files.join(', ')}"
    end

    # @group HELPERS

    # Find or initialize a calendar-object. The name comes from option --name.
    # @param [Store] store - the Store-object where to search for calendar
    # @return [Calendar]
    def find_calendar(store)
      store.find(options[:name]) || Calendar::Calendar.new(options[:name], options[:from], options[:to])
    end

    # Find the date, label, and calendar_name for an event from options
    # @yield [EventOptions]
    def get_event_options
      date = options[:new_event].fetch(:date) { Date.today.strftime('%Y-%m-%d') }
      label = options[:new_event].fetch(:label) { 'unnamed event' }
      calendar_name = options.fetch(:name) { 'calendar' }
      yield(EventOptions.new(date, label, calendar_name))
    end


    # Initialize an EventEnvironment used to operate events in stores.
    # @see #add_event
    # @yield [EventEnvironment]
    def event_environment
      get_event_options do |eo|
        event    = Calendar::CalendarEvent.new(eo[:date], eo[:label])
        store    = Persistent::DiskStore.new(CALENDAR_FILE)
        calendar = store.find(eo[:calendar_name]) || Calendar::Calendar.new(eo[:calendar_name])
        yield(EventEnvironment.new(event,store,calendar))
      end
    end

    # Save the given command and options as defaults
    def save_defaults
      store = Persistent::DiskStore.new('defaults')
      options.delete(:save_defaults)
      defaults = Defaults.new( command, options )
      store << defaults
      "Defaults saved"
    end

    # Load Defaults
    def load_defaults
      @options||=DEFAULT_OPTIONS
      store = Persistent::DiskStore.new('defaults')
      _defaults = store.find('defaults')
      if _defaults
        @command = _defaults.command
        @options.merge! _defaults.options
      end
    end

    # List saved defaults
    def list_defaults
      store = Persistent::DiskStore.new('defaults')
      defaults = store.find('defaults')
      "Command: #{defaults.command}\nOptions:\n#{list_options(defaults.options)}" if defaults
    end

    # delete saved defaults
    def clear_defaults
      store = Persistent::DiskStore.new('defaults')
      store.delete!
    end

    # print options
    # @param [Hash] _options
    def list_options(_options)
      _options.map { |_o|
        "--#{_o[0]} #{_o[1]}"
      }.join("\n")
    end

  end

  # @group HELPER CLASSES

  # EventEnvironment holds the CalendarEvent and the DiskStore, and Calendar to which the event belongs
  # @api private
  # @see RstCommand#event_environment
  class EventEnvironment < Struct.new(:event,:store,:calendar)
  end

  # EventOptions holds the options date,label, and calendar_name
  # @api private
  # @see RstCommand#get_event_options
  class EventOptions < Struct.new(:date,:label,:calendar_name,)
  end

  # Defaults Store
  # @api private
  class Defaults
    include Persistent::Persistentable

    attr_reader :command
    attr_reader :options

    def id
      'defaults'
    end

    # @param [String] command
    # @param [Hash] options
    def initialize(command,options)
      @command = command
      @options = options
    end
  end



end
