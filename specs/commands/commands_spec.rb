require_relative '../spec_helper'

include RST

describe 'Command-line arguments' do

  it "--verbose - should list interpreted options and files with --verbose", focus: true do
    got = run_shell("bin/rst ls --verbose Gemfile Rakefile README.*")
    got.split(/\n/)[1..-1].join("\n").should == <<-EOT
    Command: ls
    Options: [:verbose, true]
    Files  : Gemfile, Rakefile, README.#{ENV['RUN_SHELL'] == 'TRUE' ? 'md' : '*'}
    Gemfile	Rakefile	README.md
    EOT
    .gsub(/^\s*/,'').strip
  end

  it "ls - should list files with 'ls'" do
    run_shell("bin/rst ls -v").should =~ /Gemfile/
    run_shell("bin/rst ls --no-verbose Gemfile Rakefile").should == "Gemfile\tRakefile"
  end

  it "--help - should print help" do
    run_shell("bin/rst --help").should =~ /Usage/
  end

  it "--examples - should print out examples from doc/examples.md" do
    got = run_shell("bin/rst --examples")
    got.should == File.read(File.join(DOCS,'examples.md')).strip
  end

  it 'cal[endar] - should print a little calendar' do
    got = run_shell('bin/rst calendar --empty --from=1964-08-31 --to=1964-09-02')
    got.should =~ /Mon, Aug 31 1964/
    got.should =~ /Tue, Sep 01 1964/
    got.should =~ /Wed, Sep 02 1964/
  end

  it '(bugfix) should not list today if --to is given' do
    clear_data_path
    got = run_shell('bin/rst cal -e \'1.1.1990,Test\'')
    got+= run_shell('bin/rst cal -f \'1.1.1970\' -t \'1.1.1991\'')
    got.should_not match Date.today().strftime('%a, %b %d %Y')
    got.should_not match 'RST'
  end

  it '--name=CALENDARNAME - should store a calendar with a name' do
    run_shell('bin/rst cal --name=Birthdays --new-event \'1964-08-31,Andis Birthday\'')
    got = run_shell('bin/rst cal --name=Birthdays --from 1964-08-31 --to 1964-08-31')
    got.split(/\n/).last.should =~ /Mon, Aug 31 1964\: Andis Birthday/
  end

  it '--new-event should default to \'today\' if no date is given' do
    today = Time.now
    run_shell('bin/rst --new-event=Hello').strip.should == "Added: #{today.strftime(DEFAULT_DATE_FORMAT)}: Hello"
  end

  it '-e 1w - should interpret 1w as today+1.week' do
    today = Time.now
    due   = today+1.week
    got = run_shell('bin/rst -e 1w,Hello').strip
    got.should == "Added: #{due.strftime(DEFAULT_DATE_FORMAT)}: Hello"
  end

  it '--delete-calendar - should delete a calendar' do
    clear_data_path
    run_shell('bin/rst cal --name=Birthdays --new-event \'1964-08-31,Andis Birthday\'')
    got = run_shell('bin/rst cal --name Birthdays --from 1964-08-31 --to 1964-08-31')
    got.should =~ /Mon, Aug 31 1964\: Andis Birthday/
    run_shell('bin/rst --delete-calendar Birthdays')
    got = run_shell('bin/rst cal --name Birthdays --from 1964-08-31 --to 1964-08-31')
    got.should_not =~ /Mon, Aug 31 1964\: Andis Birthday/
  end

  it '--list-calendars - should list stored calendars' do
    clear_data_path
    run_shell('bin/rst cal --delete-calendar=unnamed')
    run_shell('bin/rst cal --delete-calendar=Birthdays --name=Birthdays --new-event="1964-08-31,Andis Birthday"')
    run_shell('bin/rst cal --name=Birthdays --new-event="1969-08-28,Heidis Birthday"')
    run_shell('bin/rst cal --name=Weddings --new-event="1991-12-28,Andi+Heidi"')
    got = run_shell('bin/rst --list-calendars')
    got.should == "Birthdays           : 2 entries\nWeddings            : 1 entry"
  end

  it '--with-ids - should list events with ids' do
    clear_data_path
    run_shell('bin/rst cal -n default -e today,Testentry')
    got = run_shell('bin/rst cal --name default -f today -t today --with-ids')
    got.should =~ /#{Date.today.strftime(DEFAULT_DATE_FORMAT)}:\n        ([a-f0-9]{8}): Testentry/
  end

  describe 'with two samples' do

    before do
      _today = '2013-05-05'
      clear_data_path
      @store = Persistent::DiskStore.new(CALENDAR_FILE)
      calendar = Calendar::Calendar.new('testcal')
      @event1 = Calendar::CalendarEvent.new( _today, 'Testentry0')
      @event2 = Calendar::CalendarEvent.new( _today, 'Testentry1')
      calendar << @event1
      calendar << @event2
      @store << calendar
    end

    it '--delete-events ID[,ID,ID,...] - should remove events from calendar' do
      run_shell("bin/rst cal -n testcal --delete-events=#{@event1.id}")
      calendar = @store.find('testcal')
      calendar.events.map(&:label).should include('Testentry1')
      calendar.events.map(&:label).should_not include('Testentry0')
    end

    it '--dump dumps a calendar' do
      got = run_shell('bin/rst -n testcal --dump').strip
      got.should == "\"#{today(:short)},Testentry0\"\n\"#{today(:short)},Testentry1\""
    end

    it '--print-calendar outputs a well formatted calendar' do
      got = run_shell('bin/rst cal -n testcal --print-calendar').strip
      _expected = <<-EOT
       testcal
             May 2013         EVENTS:
       Su Mo Tu We Th Fr Sa   Sun, May 05 2013: Testentry0 + Testentry1
                 1  2  3  4
        5  6  7  8  9 10 11
       12 13 14 15 16 17 18
       19 20 21 22 23 24 25
       26 27 28 29 30 31
      EOT
      .gsub(/^       /,'').strip
      got.should == _expected
    end

    it '--clear-defaults clears default settings' do
      save = run_shell('bin/rst -f 1900-01-01 -t 1901-01-01 --save-defaults')
      clear= run_shell('bin/rst --clear-defaults')
      save.strip.should =~ /Defaults saved/
      clear.strip.should == "1"
    end

  end

  it '--save-defaults - should save current options as defaults' do
    got = run_shell('bin/rst cal --no-empty -n unnamed --from 1.1.2013 --to 31.1.2013 --save-defaults')
    got.should =~ /Defaults saved/
    got = run_shell('bin/rst --list-defaults')
    got.should == "Command: cal\nOptions:\n--show_empty false\n--name unnamed\n--from 1.1.2013\n--to 31.1.2013"
    got = run_shell('bin/rst --verbose --no-list-defaults').should == <<-EOT
      Binary : #{ENV['RUN_SHELL'] == 'TRUE' ? 'bin/rst' : $0}
      Command: cal
      Options: [:show_empty, false], [:name, \"unnamed\"], [:from, \"1.1.2013\"], [:to, \"31.1.2013\"], [:verbose, true], [:list_defaults, false]
      Files  :
    EOT
    .gsub(/^      /,'').strip
  end

  it 'COMMAND should overwrite default command if command is given' do
    run_shell('bin/rst cal --from 1.1.2013 --to 31.1.2013 --save-defaults')
    run_shell("bin/rst ls").should =~ /Gemfile/
  end

  it 'doesn\'t thorw exectption on unknown command' do
    got = run_shell 'bin/rst undefined_command'
    got.should == ''
  end

  it 'doesn\'t throw exection on unknown options' do
    got = run_shell 'bin/rst nil --unknown-option'
    got.should =~ /invalid option: --unknown-option/
  end
end
