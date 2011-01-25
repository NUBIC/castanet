require File.expand_path('../fsms', __FILE__)

def abspath(paths)
  paths.map { |f| File.expand_path(f) }
end

abspath(Fsms).each do |machine|
  file machine => machine.sub(/#{File.extname(machine)}$/, '.rl') do |t|
    sh "ragel -R -o #{t.name} #{t.prerequisites.first}"
  end
end

namespace :fsm do
  desc 'Delete compiled state machines'
  task :clean do
    rm_f Fsms
  end

  desc 'Rebuild all state machines'
  task :rebuild => [:clean] + abspath(Fsms)
end

[ 'gem',
  'spec',
  'cucumber:all', 'cucumber:ok', 'cucumber:wip',
  'yard:auto', 'yard:once'
].each do |t|
  task t => abspath(Fsms)
end
