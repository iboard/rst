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

TDD
---

And as always we are **green**

You can find the current [coverage output][] (generated with [simplecov][])

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
[EXAMPLES at Github]: https://github.com/iboard/rst/blob/master/assets/docs/examples.md#examples
[DAV-Server]: http://dav.iboard.cc/container/rst-doc
[talk about nodoc]: http://www.youtube.com/watch?v=tCw7CpRvYOE
[Martin's code]: https://github.com/snusnu
