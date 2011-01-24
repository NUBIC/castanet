Machines = [
'lib/castanet/responses/service_validate.rb',
'lib/castanet/responses/proxy.rb'
].map { |f| File.expand_path("../#{f}", __FILE__) }

Machines.each do |machine|
  file machine => machine.sub(/#{File.extname(machine)}$/, '.rl') do |t|
    sh "ragel -R -o #{t.name} #{t.prerequisites.first}"
  end
end

namespace :fsm do
  desc 'Delete compiled state machines'
  task :clean do
    rm_f Machines
  end

  desc 'Rebuild all state machines'
  task :rebuild => [:clean] + Machines
end

[ 'spec',
  'cucumber:all', 'cucumber:ok', 'cucumber:wip',
  'yard:auto', 'yard:once'
].each do |t|
  task t => Machines
end
