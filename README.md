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

Here you can find the current [coverage output][] (generated with [simplecov][])

Running `rake` and `yard` from the project-directory the output should include
the following lines ...

    Finished in _a few_ seconds
    _n_ examples, *0* failures
    Coverage report generated for RSpec to rst/coverage. _n_ / _n+-0_ LOC (**100.0%**) covered.
    **100.00% documented**


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
