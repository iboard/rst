Ruby Shell Tools
================

RST Version 0.0.0 is an experimental Ruby2-gem by Andreas Altendorfer <andreas@altendorfer.at>

Download and Install
--------------------

You can clone the project from
**[Github](https://github.com/iboard/rst)**

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

see file [`assets/docs/examples.md`](https://github.com/iboard/rst/blob/master/assets/docs/examples.md#examples) or run

    bin/rst --examples

if you have done `rake install` you don't have to use `bin/rst` in 
  the project-directory but you can use `rst ...` from any path

Documentation
-------------

run `yard; open doc/index.html` to build the rdocs and open
it in your browser.

TDD
---

And as always we are **green**

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

