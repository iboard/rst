#!/usr/bin/env rake
require_relative 'lib/load'

options = ENV['TERM'] == 'dumb' ? '--no-color' : '--color'

# Application Tasks
task :default => 'test'

desc 'Run all specs'
task :test do
  system "rspec -f p #{options} specs"
end

desc 'Run module-specs only'
task :modules do
  system "rspec -f d #{options} specs/modules"
end

desc 'Run command-specs only (slower because of system-calls)'
task :commands do
  system "rspec -f d #{options} specs/commands"
end

desc 'Build the YARDocumentation'
task :doc do
  system 'yard'
end

desc "Deploy documentation to http://dav.iboard.cc"
task :doc_deploy do
  Rake::Task['doc'].execute
  system 'rsync','-avze','ssh', '--delete', 'doc/', 'root@dav.iboard.cc:/var/www/dav/container/rst-doc/'
  system 'rsync','-avze','ssh', '--delete', 'coverage/', 'root@dav.iboard.cc:/var/www/dav/container/rst-coverage/'
end

desc 'Build GEM'
task :build do
  Rake::Task['doc'].execute
  system 'gem build rst.gemspec'
end

desc 'Install GEM'
task :install do
  Rake::Task['build'].execute
  system "gem install rst-#{RST::VERSION}"
end
