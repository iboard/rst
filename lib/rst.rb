# Ruby Shell Tools main namespace RST
#
# @author Tue Mar 12 19:24:52 2013 <andreas@altendorfer.at>
# @see https://github.com/iboard/rst
# @see http://altendorfer.at
module RST

  require 'optparse'

  # Run commands given as ARGV with options
  class RstCommand

    attr_reader :options # the hash stores options parsed with option_parser
    attr_reader :command # the first argument of ARGV is the command

    # Initialize the Command-runner with arguments
    # normally given on the command-line. See --help
    def initialize(args)
      parse_options
    end

    # Call 'run_options' and 'run_arguments', reject empty returns and join
    # output with CR
    # @return [String]
    def run
      [run_options, run_arguments].reject{|l| l.strip == '' }.join("\n")
    end

    private

    # Interpret options from ARGV using Option Parser
    def parse_options
      @options = {}
      OptionParser.new do |opts|

        opts.banner = 'Usage: rst COMMAND [options] [FILES..]'

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

        opts.separator ''
        opts.separator 'Conmands:
          nil ... no command. Interpret options only (useful in combination with -v)
          ls .... list directory and files'.gsub(/^\s+/,'    ')
        

      end
      .parse!
    rescue => e
      puts "#{e.class} => #{e.message}"
      puts "Try #{File.basename($0)} --help"
    end

    # Run previously parsed options
    # @return [String]
    def run_options
      options.map do |k,v|
        case k.to_s
        when 'examples'; File.read(File.join(DOCS,'examples.md')).strip;
        when 'verbose' ; print_arguments;
        else
          "unknown option #{k.to_s}: #{v.inspect}"
        end
      end
      .join("\n")
    end

    # The first argument of ARGV is the 'command'
    # run known commands
    # @return [String]
    def run_arguments
      cmd = ARGV.shift
      _files = ARGV.empty? ? ['*'] : ARGV
      @command = cmd
      case command
      when nil, 'nil', 'null'; '';
      when 'ls'              ; directory_listing(_files);
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

  end

end
