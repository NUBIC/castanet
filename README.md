Castanet: a small, snappy CAS client library
============================================

Castanet is a [CAS 2.0](http://www.jasig.org/cas/protocol) client library.  It
was built at the [Northwestern University Biomedical Informatics
Center](http://www.nucats.northwestern.edu/clinical-research-resources/data-collection-biomedical-informatics-and-nubic/bioinformatics-overview.html)
as a replacement for [RubyCAS-Client](https://github.com/gunark/rubycas-client) in internal software.

Castanet does not support CAS 1.0.

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

Continuous integration reports are available at
[NUBIC's CI
server](https://ctms-ci.nubic.northwestern.edu/hudson/job/castanet/).  Castanet
is tested on Ruby 1.8.7, Ruby 1.9.2, JRuby 1.5.6, and Rubinius 1.2.0.

License
=======

Copyright (c) 2011 David Yip.  Released under the X11 (MIT) License; see LICENSE
for details.
