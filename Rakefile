require 'ci/reporter/rake/rspec'
require 'cucumber/rake/task'
require 'rspec/core/rake_task'
require 'rubygems/package_task'
require 'yard'

load File.expand_path('../lib/tasks/fsm.rake', __FILE__)
load File.expand_path('../lib/tasks/servers.rake', __FILE__)

gemspec = eval(File.read('castanet.gemspec'), binding, 'castanet.gemspec')

Gem::PackageTask.new(gemspec).define

RSpec::Core::RakeTask.new

namespace :cucumber do
  Cucumber::Rake::Task.new(:ok) do |t|
    t.profile = :default
  end

  Cucumber::Rake::Task.new(:wip) do |t|
    t.profile = :wip
  end

  desc 'Run all features'
  task :all => ['cucumber:ok', 'cucumber:wip']
end

namespace :yard do
  desc 'Run the YARD server'
  task :auto do
    sh "bundle exec yard server --reload"
  end

  desc 'Generate YARD documentation'
  YARD::Rake::YardocTask.new('once')
end

task :default => [:spec, 'cucumber:ok']
