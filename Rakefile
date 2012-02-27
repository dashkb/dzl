require 'bundler/gem_tasks'

desc 'Bust out a console'
task :console do
  exec 'pry -I lib -r diesel'
end

desc 'Boot the test app on localhost:3000'
task :server do
  exec 'rackup -p 3000'
end
