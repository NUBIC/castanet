source "http://rubygems.org"

gemspec

group :development do
  platform :jruby do
    gem 'maruku'
    gem 'json', '1.4.6'
    gem 'ZenTest', '~> 4.5.0'
  end

  platform :ruby_18, :ruby_19 do
    gem 'rdiscount'
  end

  gem 'addressable', '2.2.4'
end
