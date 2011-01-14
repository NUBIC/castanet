# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "castanet/version"

Gem::Specification.new do |s|
  s.name        = "castanet"
  s.version     = Castanet::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["David Yip"]
  s.email       = ["yipdw@northwestern.edu"]
  s.homepage    = ""
  s.summary     = %q{A CAS client library}
  s.description = %q{A small, snappy CAS 2.0 client library for Ruby applications}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  [
    [ 'cucumber',       nil         ],
    [ 'rspec',          '~> 2.0'    ],
    [ 'rubycas-server', nil         ],
    [ 'yard',           nil         ],

    # if this isn't specified, Bundler will drag in ActiveRecord 1.6.0 for
    # RubyCAS-Server -- not really sure why
    [ 'activerecord',   '~> 3.0'    ],

    # RubyCAS-Server in Cucumber scenarios uses an SQLite3 database
    [ 'sqlite3-ruby',   nil         ]
  ].each do |gem, version|
    s.add_development_dependency gem, version
  end
end
