require_relative '../spec_helper'

include RST

describe RST::CursesController do

  before do
    Curses = mock(Curses)
    std_scr = mock( 'StdScreenMock' )
    std_scr.stub! :keypad
    %i(noecho init_screen close_screen init_pair attron setpos 
       start_color keypad addstr color_pair).each do |_stub|
      Curses.stub! _stub
    end
    Curses.stub!(:stdscr).and_return(std_scr)
    Curses.stub!(:cols).and_return(80)
    Curses.stub!(:lines).and_return(3)
    Curses.stub!(:clear).and_return(true)
    Curses.stub!(:attron).and_yield

    @controller = RST::CursesController.new
  end

  it '.initialize with program-arguments' do
    @controller.should_not be_nil
  end

  it 'should respond to print_screen' do
    Curses.should_receive(:setpos)
    @controller.print_screen(["Line"]*3)
  end

  it 'should respond to clear' do
    Curses.should_receive(:clear)
    @controller.clear
  end

  it 'should respond to noop' do
    Curses.should_receive(:addstr)
    @controller.noop
  end

  it 'should close curses screen on CG' do
    Curses.should_receive(:close_screen)
    @controller = nil
    GC.start
  end

end


