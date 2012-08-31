require 'rake/gempackagetask'
require 'ci/reporter/rake/rspec'
require 'cucumber/rake/task'
require 'rspec/core/rake_task'
require 'yard'

load File.expand_path('../fsm.rake', __FILE__)

gemspec = eval(File.read('castanet.gemspec'), binding, 'castanet.gemspec')

Rake::GemPackageTask.new(gemspec).define

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

namespace :rbx do
  desc 'Remove Rubinius compilation products'
  task :clean do
    rm Dir['**/*.rbc']
  end
end
