Castanet: a small, snappy CAS client library
============================================

Castanet is a [Central Authentication Service](http://www.jasig.org/cas) (CAS)
client library.  It implements version 2.0 of the CAS protocol.

Castanet was built at the [Northwestern University Biomedical Informatics
Center](http://www.nucats.northwestern.edu/clinical-research-resources/data-collection-biomedical-informatics-and-nubic/bioinformatics-overview.html)
as a replacement for [RubyCAS-Client](https://github.com/gunark/rubycas-client)
in internal software.

Castanet is tested on Ruby 1.8.7, Ruby 1.9.2, JRuby 1.5.6 in Ruby 1.8 mode, and Rubinius 1.2.0.
Continuous integration reports are available at [NUBIC's CI
server](https://ctms-ci.nubic.northwestern.edu/hudson/job/castanet/).

Getting started
===============

Mix `Castanet::Client` into the objects that need CAS client behavior.

Objects that include `Castanet::Client` must implement `cas_url`,
`proxy_callback_url`, and `proxy_retrieval_url`.

See the documentation for `Castanet::Client` for more information and usage
examples.

Acknowledgments
===============

Castanet's test harness was based off of code originally written by [Rhett
Sutphin](mailto:rhett@detailedbalance.net).

Query string building code was taken from [Rack](http://rack.rubyforge.org/).

Development
===========

Castanet uses [Bundler](http://gembundler.com/) version `~> 1.0` for dependency
management.

Some of Castanet's development dependencies work best in certain versions of
Ruby.  Additionally, some implementations of Ruby do not support constructs
(i.e. `fork`) used by Castanet's tests.  For this reason, Castanet's Cucumber
scenarios use [RVM](http://rvm.beginrescueend.com/) to run servers in
appropriate Ruby implementations.

Castanet's CAS response parsers are implemented using
[Ragel](http://www.complang.org/ragel/).

Once you've got Bundler, RVM, and Ragel installed and set up:

    $ bundle install
    $ rake udaeta:install_dependencies --trace   # because it helps to see what's going on
    $ rake ci --trace                            # ditto

Assuming you cloned Castanet at a point where its CI build succeeded, all steps
should pass.  If they don't, feel free to ping me.

License
=======

Copyright (c) 2011 David Yip.  Released under the X11 (MIT) License; see LICENSE
for details.
