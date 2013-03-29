require_relative '../spec_helper'

include RST

describe 'Command-line arguments' do

  it "should list interpreted options and files with --verbose" do
    got = run_shell("bin/rst ls --verbose Gemfile Rakefile README.*")
    got.should == <<-EOT
    Binary : bin/rst
    Command: ls
    Options: [:name, "unnamed"], [:from, "today"], [:to, "today"], [:show_empty, false], [:verbose, true]
    Files  : Gemfile, Rakefile, README.md
    Gemfile	Rakefile	README.md
    EOT
    .gsub(/^\s*/,'').strip
  end

  it "should list files with 'ls'" do
    run_shell("bin/rst ls").should =~ /Gemfile/
    run_shell("bin/rst ls Gemfile Rakefile").should == "Gemfile\tRakefile"
  end

  it "should print help with --help" do
    run_shell("bin/rst --help").should =~ /Usage/
  end

  it "should print out examples with --examples" do
    got = run_shell("bin/rst --examples")
    got.should == File.read(File.join(DOCS,'examples.md')).strip
  end

  it 'should print a little calendar' do
    got = run_shell('bin/rst calendar --empty --from=1964-08-31 --to=1964-09-02')
    got.should =~ /Mon, Aug 31 1964/
    got.should =~ /Tue, Sep 01 1964/
    got.should =~ /Wed, Sep 02 1964/
  end

  it 'should not list today if --to is given (bugfix)' do
    got = run_shell('bin/rst cal -e 1.1.1990,Test')
    got+= run_shell('bin/rst cal -f 1.1.1970 -t 1.1.1991')
    got.should_not match Date.today().strftime('%a, %b %d %Y')
    got.should_not match 'RST'
  end

  it 'should store a calendar with a name' do
    run_shell('bin/rst cal --name=Birthdays --new-event="1964-08-31,Andis Birthday"')
    got = run_shell('bin/rst cal --name=Birthdays --from=1964-08-31 --to=1964-08-31')
    got.should =~ /Mon, Aug 31 1964\: Andis Birthday/
  end

  it 'should delete a calendar' do
    run_shell('bin/rst cal --name=Birthdays --new-event="1964-08-31,Andis Birthday"')
    got = run_shell('bin/rst cal --name=Birthdays --from=1964-08-31 --to=1964-08-31')
    got.should =~ /Mon, Aug 31 1964\: Andis Birthday/
    run_shell('bin/rst --delete-calendar Birthdays')
    got = run_shell('bin/rst cal --name=Birthdays --from=1964-08-31 --to=1964-08-31')
    got.should_not =~ /Mon, Aug 31 1964\: Andis Birthday/
  end

  it 'should list calendars' do
    run_shell('bin/rst cal --delete-calendar=Birthdays --name=Birthdays --new-event="1964-08-31,Andis Birthday"')
    run_shell('bin/rst cal --name=Birthdays --new-event="1969-08-28,Heidis Birthday"')
    run_shell('bin/rst cal --name=Weddings --new-event="1991-12-28,Andi+Heidi"')
    got = run_shell('bin/rst --list-calendars')
    got.should == "unnamed             : 1 entry\nBirthdays           : 2 entries\nWeddings            : 1 entry"
  end

  it 'should save defaults with --save-defaults' do
    got = run_shell('bin/rst cal --from 1.1.2013 --to 31.1.2013 --save-defaults')
    got.should == 'Defaults saved'
    got = run_shell('bin/rst --list-defaults')
    got.should == "Command: cal\nOptions:\n--name unnamed\n--from 1.1.2013\n--to 31.1.2013\n--show_empty false"
    got = run_shell('bin/rst --verbose').should == <<-EOT
      Binary : bin/rst
      Command: cal
      Options: [:name, \"unnamed\"], [:from, \"1.1.2013\"], [:to, \"31.1.2013\"], [:show_empty, false], [:verbose, true]
      Files  :
    EOT
    .gsub(/^      /,'').strip
  end

end
