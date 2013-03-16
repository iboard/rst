Ruby Shell Tools
================

RST Version 0.0.1 is an experimental Ruby2-gem by Andreas Altendorfer <andreas@altendorfer.at>

Install from rubygems.org
-------------------------

    gem install rubyshelltools


Clone from Github
-----------------

You can clone the project from **[Github](https://github.com/iboard/rst)**

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

 * [At Github](https://github.com/iboard/rst/blob/master/assets/docs/examples.md#examples)
 * [loacal copy](./file.examples.html)
 
or run

    bin/rst --examples

if you have done `rake install` you don't have to use `bin/rst` in 
the project-directory but you can use `rst ...` directly from the shell.

Documentation
-------------

run `yard; open doc/index.html` to build the rdocs and open
it in your browser.

The documentation can be found also at
[dav.iboard.cc](http://dav.iboard.cc/container/rst-doc)

TDD
---

And as always we are **green**

You can find the current output of [simplecov][] at [dav.iboard.cc](http://dav.iboard.cc/container/rst-coverage)


> $ rake
>
> Finished in _a few_ seconds
>
> _n_ examples, 0 failures
>
> Coverage report generated for RSpec to rst/coverage. _n_ / _n+-0_ LOC (**100.0%**) covered.
>
> $ yard
>
> Files:          _n_
>
> Modules:         _n_ (    0 undocumented)
>
> Classes:         _n_ (    0 undocumented)
>
> Constants:      _n_ (    0 undocumented)
>
> Methods:        _n_ (    0 undocumented)
>
> **100.00% documented**


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
