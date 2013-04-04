#!/usr/bin/env rake
require_relative 'lib/load'

options = ENV['TERM'] == 'dumb' ? '--no-color' : '--color'


def ask prompt, allow
  loop do
    printf( "%s (%s):" % [prompt, "[#{allow.first}]#{allow[1..-1].join('/')}"])
    answer = $stdin.gets
    break answer.strip if allow.include?(answer.strip)
    break allow.first if answer == "\n"
    puts "Please answer #{allow.join('/')} or press Ctrl+C to abort"
  end
end


# Application Tasks
task :default => 'test'

desc 'Run Module-specs w/o command-line calls'
task :test do
  system "rspec -f p #{options} specs/core_extensions specs/modules"
end

desc 'Run all tests including specs/commands'
task :all do
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
  system 'gem build rubyshelltools.gemspec'
end

desc 'Deploy (all, and to RubyGems.org)'
task :deploy do
  Rake::Task['test'].execute
  system 'git', 'status'
  if ask('Are you sure everything is green?', %W(y n)) == 'y'
    Rake::Task['build'].execute
    Rake::Task['doc_deploy'].execute
    system 'git', 'push', 'origin'
    system 'git', 'push', 'github'
    system 'gem', 'push', "rubyshelltools-#{RST::VERSION}.gem"
  else
    puts "see you later!"
  end
end

desc 'Install GEM'
task :install do
  Rake::Task['build'].execute
  system "gem install rubyshelltools-#{RST::VERSION}"
end
