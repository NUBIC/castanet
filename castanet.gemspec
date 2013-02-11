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

  s.files         = Dir.glob("{.yardopts,README,CHANGELOG,LICENSE,lib/**/*}")
  s.test_files    = Dir.glob("cucumber.yml,{spec,features}/**/*")
  s.executables   = []
  s.require_paths = ["lib"]

  [
    [ 'autotest',       nil         ],
    [ 'ci_reporter',    nil         ],
    [ 'cucumber',       nil         ],
    [ 'mechanize',      nil         ],
    [ 'rack',           nil         ],
    [ 'rake',           nil         ],
    [ 'rspec',          '>= 2.12.0' ],
    [ 'travis-lint',    nil         ],
    [ 'webmock',        nil         ],
    [ 'yard',           nil         ]
  ].each do |gem, version|
    s.add_development_dependency gem, version
  end
end
