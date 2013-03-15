require_relative '../spec_helper'

include RST

describe 'Command-line arguments' do

  it "should list interpreted options and files with --verbose" do
    got = run_shell("bin/rst ls --verbose Gemfile Rakefile README.*")
    got.should == <<-EOT
    Binary : bin/rst
    Command: 
    Options: [:name, "unnamed"], [:from, "today"], [:to, "today"], [:verbose, true]
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
    got = run_shell('bin/rst calendar --from=1964-08-31 --to=1964-09-02')
    got.should =~ /Mon, Aug 31 1964/
    got.should =~ /Tue, Sep 01 1964/
    got.should =~ /Wed, Sep 02 1964/
  end

  it 'should store a calendar with a name' do
    run_shell('bin/rst cal --name=Birthdays --new-event="1964-08-31,Andis Birthday"')
    got = run_shell('bin/rst cal --name=Birthdays --from=1964-08-31 --to=1964-08-31')
    got.should =~ /Mon, Aug 31 1964\: Andis Birthday/
  end

end
