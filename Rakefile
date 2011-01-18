require 'cucumber/rake/task'
require 'rspec/core/rake_task'

namespace :cucumber do
  Cucumber::Rake::Task.new(:ok) do |t|
    t.profile = :default
  end

  Cucumber::Rake::Task.new(:wip) do |t|
    t.profile = :wip
  end

  desc 'Run all features'
  task :all => [:ok, :wip]
end

RSpec::Core::RakeTask.new
