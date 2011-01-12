require 'bundler'
require 'cucumber/rake/task'

Bundler::GemHelper.install_tasks

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
