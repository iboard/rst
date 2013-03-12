#!/usr/bin/env rake
require './rst'
require './lib/rst'

# Application Tasks
task :default => 'test'

desc "Run specs"
task :test do
  options = ENV['TERM'] == 'dumb' ? '--no-color' : '--color'
  system "rspec -f d #{options} specs"
end

desc "Build GEM"
task :build do
  system "gem build rst.gemspec"
end

desc "Install GEM"
task :install do
  Rake::Task["build"].execute
  system "gem install rst-#{RST::VERSION}"
end
