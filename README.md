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

License
=======

Copyright (c) 2011 David Yip.  Released under the X11 (MIT) License; see LICENSE
for details.
