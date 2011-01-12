# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "bccas/client/version"

Gem::Specification.new do |s|
  s.name        = "bccas-client"
  s.version     = Bccas::Client::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["David Yip"]
  s.email       = ["yipdw@northwestern.edu"]
  s.homepage    = ""
  s.summary     = %q{A CAS client library}
  s.description = %q{A CAS client library built for NUBIC's Ruby webapps}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'cucumber'
  s.add_development_dependency 'rubycas-server'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'sinatra'
  s.add_development_dependency 'yard'
end
