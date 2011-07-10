1.0.1 (unreleased)
==================

Minor enhancements
------------------

- Moved setup and usage examples to readme.

1.0.0 (2011-02-18)
==================

Backwards-incompatible changes
------------------------------

- `Castanet::Client#https_disabled` has changed to
  {Castanet::Client#https_required}, and mixed HTTP/HTTPS communication is now
  possible.  See the documentation of {Castanet::Client} for more information.
- {Castanet::ProxyTicket#reify!} no longer returns `self`.

0.0.2 (2011-02-14)
==================

Errors fixed
------------

- `castanet/client.rb` now `require`s `net/https` to properly activate the
  HTTPS bits of `Net::HTTP`.  (Dates to version 0.0.1.)
- A formatting error in the documentation for `Castanet::ProxyTicket` was
  fixed.  (Dates to version 0.0.1.)

Minor enhancements
------------------

- Included this changelog in the YARD docs.

0.0.1 (2011-02-03)
==================

- Initial release.
