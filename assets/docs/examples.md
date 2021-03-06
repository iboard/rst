EXAMPLES
========

rst --help
----------
 
Print out available options and commands
  
    $ rst --help

        Usage: rst [COMMAND] [options] [FILES..]

        Options:
            -v, --[no-]verbose               Run verbosely
                --examples                   Show some usage examples
            -h, --help                       Print help
            -f, --from DATE                  Set from-date
            -t, --to DATE                    Set to-date
            -n, --name NAME                  Use this name for the command
            -e, --new-event [DATE,]STRING    Add an event
                --list-calendars             List available calendars
                --delete-calendar CALENDARNAME
                                             Delete an calendar and all it's entries!
                --delete-events ID[,ID,...]  delete entries from calendar
                --[no-]empty                 Show empty entries
            -i, --with-ids                   List entries with ids
            -d, --dump                       Dump calendar-events
                --save-defaults              Save given params as defaults
                --list-defaults              list saved defaults
                --clear-defaults             delete previously saved defaults
            -p, --print-calendar             Print calendar

        Commands:
            nil .......... No command. Interpret options only (useful in combination with -v)
            ls ........... List directory and files
            cal[endar] ... Print a calendar --from --to

        DATE-FORMATS FOR --new-event:
            omitted....... Today
            today ........ Today
            nDWM ......... Today + n days, weeks, months eg 1w, 2d[ays], 1M[ONTH]
            yyyy-mm-dd
            dd.mm.yyyy
            mm/dd/yyyy

            Use --example for a more detailed list of commands.
rst ls *
--------

List directory and files

    $ rst ls *
    Gemfile	Gemfile.lock	README.md	Rakefile	assets	bin	lib	
    rst-0.0.0.gem	rst.gemspec	rst.rb	specs


rst [nil]  -v SOME FILES HERE
-----------------------------

show the arguments and options parsed from command-line

    $ rst -v SOME FILES HERE
    Binary : /Users/aa/.rvm/gems/ruby-head@ruby2/bin/rst
    Command: 
    Options: [:verbose, true]
    Files:   SOME, FILES, HERE
    
rst calendar
------------

RST supports a (very) simple calendar-function. You can store (all-day)events for a given date.
The calendar can be stored persistently in a PStore file. The default
location of the file is within the GEM-path/data/development. You can
overwrite this by defining env-vars for RST_DATA and RST_ENV
    
    $ export RST_DATA=$HOME/.rst/data
    $ export RST_ENV=production
    
    $ rst cal --new-event='1964-08-31,Birthday Andreas Altendorfer'
    $ rst cal -e 'today,Win the jackpot'  # e is an abbreviation for --new-event
    $ rst cal -f 1964/1                   # f is an abbreviation for --from
    Mon, Aug 31 1964: Birthday Andreas Altendorfer
    Fri, Mar 15 2013: Win the jackpot
    
    $ find $HOME/.rst
    /Users/you/.rst
    /Users/you/.rst/data
    /Users/you/.rst/data/production
    /Users/you/.rst/data/production/CALENDAR_FILE
    
    $ rst --list-calendars
    birthdays           : 5 entries
    work                : 2 entries
    
    $ rst -e 1w,Some Event  # entered on Tue, Jan 01 2013
    Added: Tue, Jan 08 2013: Some Event 

The full set of parameters is

    $ rst calendar --from='1964-01-01' --to='today' --empty
    Wed, Jan 01 1964: 
    Thu, Jan 02 1964: 
    Fri, Jan 03 1964: 
    Sat, Jan 04 1964: 
    #.... some other empty lines
    Mon, Aug 31 1964: Birthday Andreas Altendorfer
    # .... some thousand other empty lines
    Fri, Mar 15 2013: Win the jackpot

* --empty ...... show empty lines
* --no-empty ... show no empty lines (default)

List entries with IDs and delete by ID
--------------------------------------

    $ rst cal -i
    Sun, Mar 31 2013:
      e5e14e59 > Your Event ...
    
    $ rst cal --delete-event e5e14e59

Print a pretty calendar
-----------------------

        $ rst cal -n work --print-calendar
        
             April 2013        EVENTS:
        Su Mo Tu We Th Fr Sa   Wed, Apr 24 2013: RailsConf2013 7h Departure Munich + TUV Audit
            1  2  3  4  5  6   Mon, Apr 29 2013: RailsConf2013
         7  8  9 10 11 12 13   Tue, Apr 30 2013: RailsConf2013
        14 15 16 17 18 19 20   Wed, May 01 2013: RailsConf2013
        21 22 23 24 25 26 27   Thu, May 02 2013: RailsConf2013
        28 29 30               Fri, May 03 2013: RailsConf2013
                               Sat, May 04 2013: RailsConf2013 Arrival Munich
                               Mon, May 06 2013: Exam Romy
              May 2013
        Su Mo Tu We Th Fr Sa
                  1  2  3  4
         5  6  7  8  9 10 11
        12 13 14 15 16 17 18
        19 20 21 22 23 24 25
        26 27 28 29 30 31



Save defaults
=============

You can save options with `--save-defaults` and then cal rst without
options to execute it with command and saved-options 

    $ rst calendar --from '1964-01-01' --to today --save-defaults
    Defaults Saved
    Mon, Aug 31 1964: Birthday Andreas Altendorfer
    
    $ rst
    Mon, Aug 31 1964: Birthday Andreas Altendorfer

You can delete saved options with `--clear-defaults` or list saved
options with `--list-defaults`


