Gem::Specification.new do |s|
  s.name        = 'rst'
  s.version     = '0.0.0'
  s.date        = '2013-03-12'
  s.summary     = "Ruby Shell Tools"
  s.description = "Tools for the unix shell"
  s.authors     = ["Andi Altendorfer"]
  s.email       = 'andreas@altendorfer.at'
  s.files       = Dir['lib/**/*.rb'] + Dir['bin/*']
  s.bindir      = 'bin'
  s.executables = ['rst']
  s.default_executable = 'rst'
  s.executables << 'rst'
  #s.add_dependency('somegem')
  s.add_development_dependency('redcarpet')
  s.add_development_dependency('rspec')
  s.add_development_dependency('yard')
  s.extra_rdoc_files = ['README.md', 'assets/docs/examples.md']
  s.homepage    = 'http://rubygems.org/gems/rst'
end
