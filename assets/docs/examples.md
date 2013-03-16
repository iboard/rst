EXAMPLES
========

rst --help
----------
 
Print out available options and commands
  
    $ rst --help
    Usage: rst [COMMAND [COMMAND ....]] [options] [FILES..]

    Options:
        -v, --[no-]verbose               Run verbosely
            --examples                   Show some usage examples
        -h, --help                       Print help
        -f, --from DATE                  Set from-date
        -t, --to DATE                    Set to-date
        -n, --name NAME                  Use this name for the command
        -e, --new-event DATE,STRING      Add an event
            --[no-]empty                 Show empty entries
    Commands:
        nil .......... no command. Interpret options only (useful in combination with -v)
        ls ........... list directory and files
        cal[endar] ... print a calendar --from --to

        use --example for a more detailed list of commands.

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

