Ruby Shell Tools
================

RubyShellTools, RST is an experimental Ruby2-gem by Andreas Altendorfer <andreas@altendorfer.at>


Inspired by this [talk about nodoc][] and by the clean style of
[Martin's code][],  I've playing around with Ruby2, Yard, and my idea of
clean code with this gem named 'RubyShellTools' (short RST, but this
name wasn't available at rubygems anymore ;-)

Since bash-history isn't always enough persistent for my daily work, I deal with the idea to create a kinda 'central toolbox' for my shell. RST represents the first steps in this direction. I'm not sure if the 'project' will survive, tho. I'll give it a try.

The first pushed version features a very simple 'ls' and 'calendar'-command. The plan is to play around with the structure of the gem until I'm satisfied and feel comfortable to start implementing more features. There's a ton of ideas what RST could do, I'm just not sure what it shall do. Let's see ...


Install from rubygems.org
-------------------------
 
Find the gem at [RubyGems.org][]

    gem install rubyshelltools
    export RST_DATA=$HOME/.rst # default:  GEM_PATH/rubyshelltools/data
    export RST_ENV=production  # defaults: development
    rst --help


Clone/Fork from Github
----------------------

You can clone from or fork the project at => [Github][]

    git clone git://github.com/iboard/rst.git

### First steps ...

After downloading the project you can do

    cd rst
    bundle       # install required Gems
    rake         # Run all specs
    rake build   # build the gem
    rake install # build and install gem


Usage
-----

see file EXAMPLES.md:

 * [EXAMPLES on Github][]
 * [loacal copy](./file.examples.html)
 
or run

    bin/rst --examples

if you have done `rake install` you don't have to use `bin/rst` in 
the project-directory but you can use `rst ...` directly from the shell.

Documentation
-------------

run `yard; open doc/index.html` to build the rdocs and open
it in your browser.

The latest version is online at my [DAV-server][] too.

Browsing the code
-----------------

  **To get a glue what's goin on**

  do a `rspec --format d spec/` in the project's root

        Command-line arguments
          --verbose - should list interpreted options and files with --verbose
          ls - should list files with 'ls'
          --help - should print help
          --examples - should print out examples from doc/examples.md
          cal[endar] - should print a little calendar
          (bugfix) should not list today if --to is given
          --name=CALENDARNAME - should store a calendar with a name
          --new-event should default to 'today' if no date is given
          -e 1w - should interpret 1w as today+1.week
          --delete-calendar - should delete a calendar
          --list-calendars - should list stored calendars
          --with-ids - should list events with ids
          --delete-events ID[,ID,ID,...] - should remove events from calendar
          --save-defaults - should save current options as defaults
          COMMAND should overwrite default command if command is given

        Ruby core-extensions
          Numeric
            should support calendar-functions
          String
            should respond to blank?

        Exceptions
          RST::AbstractMethodCallError
            .message should include backtrace-information

        Initialize logger
          should log to stderr

        RST::Calendar::CalendarEvent
          should initialize with a date and a label
          should output the label as event's headline
          should generate an id if no id-method defined yet

        Calendar module:
          Calendar Class
            .new(name,from,to) should initialize with Date-objects
            .new(name,str_from,str_to) should initialize with strings
            .span should return number of days between start and end
            .list_days(from,to,true) should list week days
            .list_days(from,to,true) should display lines with entries if empty==true (bugfix)
            .new(name,string,string) should interpret today as argument
            .new(name,nil,string) should default to 'today' if an argument is missing
            .new(name, string) should interpret -e 1w as today+1week
            .form=, .to=, setter method for :from, and :to should be defined
            .id should be the name of the calendar
            .to_text(name,from,to) should output a pretty formatted calendar
          Eventable module
            .event_date - should be injected to the object
            .scheduled? should return true if the object is scheduled
            .schedule!(date) should schedule the object
            .event_headline() should respond with a simple string representation
            .event_headline() should be overwritten
          A calendar with event-able objects
            Calendar
              .list_days(start_on,end_on,show_empty,show_ids=false) shows entries between start_on and end_on
              .list_days(nil,nil,false,true) show entries with :id and :calendar-name
              .dump(show_ids=false) calendar-events
                (false) plain dump only
                (true) dumps with id and calendar

        RST::Persistent
          Abstract Store
            should raise an exception if setup_store is not overwritten
            if setup_store is overwritten but no other abstract method
              should raise an exceptions if abstract methods not overwritten
              should delete the store
          MemoryStore
            should initialize an in-memory store
            should be able to add and retrieve from store
            should remove objects from store
            should have persistence functions
            should persist an object
            should find an object by id
            should find more than one object with find
            should return nil if nothing is found
            .create should act as a factory for objects
            .delete should delete the store
            should not allow to move the store once it's set
          DiskStore
            .delete! should remove the file
            .<< should add an object and store it to disk
            should remove objects from store
            .<< should update existing objects rather than add new objects
          Persistentable
            in a MemoryStore
              .id should be a random hex if object doesn't provide an id
              .save updates the object in the store
              .delete removes the object from it's store
            in a DiskStore
              .save updates the object in the store
              .delete removes the object from it's store

        Finished in 6.82 seconds
        65 examples, 0 failures
        Coverage report generated for RSpec to /Users/aa/Development/ruby2/rst/coverage. 596 / 596 LOC (100.0%) covered.

  **modules**
  
 Modules are the core of this project. Within the directory
 `lib/modules` you'll find

     * calendar           # Everything about Calendars 
       * calendar         # The Calendar-module and -class
       * eventable        # Eventable API (module to make a class an event)
       * calendar_event   # CalendarEvent-class
      
     * persistent         # Make things persistent
       * persistent       # The Persistent-Module defines Persistentable/API
       * store            # The abstract Store-class
       * memory_store     # Store-descendant for a non-persistent memory-store
       * disk_store       # Store-descendant using ruby-PStore to save to disk


  **command-line implementation**
  
     * ./rst.rb           # Defines global Constants and the Logger
     * ./lib/rst.rb       # Defines the class RstCommand used for the
                          #   command-line-implementation
     * ./lib/load.rb      # requires all necessary files
                          #   used by bin/rst and spec/spec_helper.rb
     * ./bin/rst          # Loads the library and instantiates a
                          #   RstCommand-object

  **RstCommand**

Can handle two commands by now: 

_ls_, 
  the directory-listing, is coded
inline and does a simple Dir for the given wildcards.

_print_calendar_,
  opens the calendar-file (all calendars are stored in one file) and acts on the calendar 
named by the --name parameter. It uses _DiskStore_ to make the calendars
persistent.

      cal = find_calendar( Persistent::DiskStore.new(CALENDAR_FILE) )
      cal.list_days(options[:from], options[:to], options[:show_empty]).compact.join("\n")
  


TDD
---

And as always we are **green**

See the current [coverage output][] (generated with [simplecov][])

Running `rake` and `yard` from the project-directory the output should include
the following lines ...

    Finished in _a few_ seconds
    _n_ examples, *0* failures
    Coverage report generated for RSpec to rst/coverage. _n_ / _n+-0_ LOC (**100.0%**) covered.
    **100.00% documented**

To run specs you can use rake-tasks

    rake [test]      # Run Module-specs w/o command-line calls (default)
    rake all         # Run all tests including specs/commands
    rake commands    # Run command-specs only (slower because of system-calls)
    rake modules     # Run module-specs only

License
=======

This is free software
---------------------

Use it without restrications and on your own risk.
Leaving the copyright is appreciated, though.


Copyright
---------

(c) 2013 by Andreas Altendorfer


[simplecov]: http://github.com/colszowka/simplecov 
[RubyGems.org]: https://rubygems.org/gems/rubyshelltools
[coverage output]: http://dav.iboard.cc/container/rst-coverage
[Github]: https://github.com/iboard/rst
[EXAMPLES on Github]: https://github.com/iboard/rst/blob/master/assets/docs/examples.md#examples
[DAV-Server]: http://dav.iboard.cc/container/rst-doc
[talk about nodoc]: http://www.youtube.com/watch?v=tCw7CpRvYOE
[Martin's code]: https://github.com/snusnu
