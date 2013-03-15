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

see file `assets/docs/examples.md` or run

    bin/rst --examples

if you have done `rake install` you don't have to use `bin/rst` in 
  the project-directory but you can use `rst ...` from any path

Documentation
-------------

run `yard; open doc/index.html` to build the rdocs and open
it in your browser.


License
=======

This is free software
---------------------

Use it without restrications and on your own risk.
Leaving the copyright is appreciated, though.


Copyright
---------

(c) 2013 by Andreas Altendorfer

