require 'curses'

module RST

  class CursesController

    include Curses

    COLORS = [ COLOR_BLACK,COLOR_RED,COLOR_GREEN,COLOR_YELLOW,COLOR_BLUE,
               COLOR_MAGENTA,COLOR_CYAN,COLOR_WHITE ]

    # @group public api

    def initialize(*)
      init_curses
      ObjectSpace.define_finalizer( self, self.class.finalize )
      clear
    end

    # Outputs array of lines from 0,0 to max-lines
    # @param [Array] lines - lines to output
    def print_screen(lines)
      lines.each_with_index do |line,lno|
        write(lno, 0, block_given? ? yield(line,lno) : line)
        break if lno > height-3
      end
    end


    # update the status-line
    # @param [String] message
    def status(message)
      message += '-' * (status_line_length - message.length)
      write(status_line, 0, message, 1 )
    end

    def noop
      write(0,0,"NOOP #{Time.now.to_s}"+" "*5)
    end

    def clear
      Curses.clear
      status "q=Quit c=Calendar <enter>=Clear screen"
    end

    private

    def write(line, column, text, color_pair=@color_pairs.sample)
      Curses.setpos(line, column)
      Curses.attron(color_pair(color_pair)|A_NORMAL) do
        Curses.addstr(text+ ' '*(status_line_length-column-text.length))
      end
    end

    def height
      Curses.lines
    end

    def init_curses
      Curses.noecho # do not show typed keys
      Curses.init_screen
      Curses.start_color
      @screen=Curses.stdscr
      @screen.keypad(true) # enable arrow keys
      init_colors
    end

    def init_colors
      @color_pairs = []
      COLORS.each_with_index do |fg,fgi|
        (COLORS-[fg]).each_with_index do |bg,bgi|
          Curses.init_pair(fgi*10+bgi,fg,bg)
          @color_pairs << fgi*10+bgi
        end
      end
    end

    def status_line_length
      Curses.cols
    end

    def status_line
      Curses.lines-1
    end

    def self.finalize
      proc do
        Curses.close_screen
      end
    end

  end
end
