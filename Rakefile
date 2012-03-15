require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

desc 'Bust out a console'
task :console do
  exec 'pry -I lib -r dzl'
end

desc 'Boot the test app on localhost:3000'
task :server do
  exec 'rackup -p 3000'
end

desc 'Run the specs'
RSpec::Core::RakeTask.new('spec')