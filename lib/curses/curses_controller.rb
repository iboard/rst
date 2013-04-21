require 'curses'

module RST

  # Controll the curses-lib
  # @example
  #   cc = CursesController.new
  #   cc.print_scren( ['Line 1', 'Line 2', ...] )
  #   cc.clear
  #   cc.status 'It works'
  #
  class CursesController

    include Curses

    # Available colors provided by Curses
    COLORS = [ COLOR_BLACK,COLOR_RED,COLOR_GREEN,COLOR_YELLOW,COLOR_BLUE,
               COLOR_MAGENTA,COLOR_CYAN,COLOR_WHITE ]

    # @group public api

    # Initialize and register a finalizer to close curses
    # whenever this object gets destroyed by the GC.
    def initialize(*)
      init_curses
      ObjectSpace.define_finalizer( self, self.class.finalize )
      clear
    end

    # Outputs array of lines from 0,0 to max-lines
    # @param [Array] lines - lines to output
    def print_screen(lines)
      color_pair = 1
      lines.each_with_index do |line,lno|
        color_pair = color_pair == 1 ? 2 : 1
        write(lno, 0, block_given? ? yield(line,lno) : line, color_pair)
        break if lno > height-3
      end
    end


    # update the status-line
    # @param [String] message
    def status(message)
      message += '-' * (status_line_length - message.length)
      write(status_line, 0, message, 1 )
    end

    # No operation - called when an unknown key is pressed
    # to show any response
    def noop
      write(0,0,"NOOP #{Time.now.to_s}"+" "*5)
    end

    # Clear the screen and rewrite the status-bar
    def clear
      Curses.clear
      status "q=Quit c=Calendar <enter>=Clear screen"
    end

    #@endgroup

    private

    # Output a line of text and clear to the end of line
    # @param [Integer] line - the line to write to 0=top of screen
    # @param [Integer] column - the column to start at 0=left most col.
    # @param [String] text - the text to write
    # @param [Integer] color_pair - which color to use (or random)
    def write(line, column, text, color_pair=@color_pairs.sample)
      Curses.setpos(line, column)
      Curses.attron(color_pair(color_pair)|A_NORMAL) do
        Curses.addstr(text+ ' '*(status_line_length-column-text.length))
      end
    end

    # @return [Integer] - number of lines available at current screen
    def height
      Curses.lines
    end

    # Initialize the Curses-environment
    def init_curses
      Curses.noecho # do not show typed keys
      Curses.init_screen
      Curses.start_color
      @screen=Curses.stdscr
      @screen.keypad(true) # enable arrow keys
      init_colors
    end

    # Create color-pairs fg/bg for each combination of
    # given colors (see top of file)
    def init_colors
      @color_pairs = []
      COLORS.each_with_index do |fg,fgi|
        (COLORS-[fg]).each_with_index do |bg,bgi|
          Curses.init_pair(fgi*10+bgi,fg,bg)
          @color_pairs << fgi*10+bgi
        end
      end
    end

    # @return [Integer] - number of columns (width) of the screen
    def status_line_length
      Curses.cols
    end

    # @return [Integer] - bottom of screen
    def status_line
      Curses.lines-1
    end


    # Finalize get's called when the CG will free the object.
    # The call to this function was registered in the constructor.
    def self.finalize
      proc do
        Curses.close_screen
      end
    end

  end
end
