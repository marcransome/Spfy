# -*- encoding: utf-8 -*-
require File.expand_path('../lib/spfy/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name            = "spfy"
  gem.version         = Spfy::VERSION
  gem.summary         = 'XSPF playlist generator'
  gem.description     = 'Spfy is a simple command-line tool for generating XSPF playlists from metadata stored in several popular audio formats.'
  gem.authors         = ["Marc Ransome"]
  gem.email           = 'marc.ransome@fidgetbox.co.uk'
  gem.files           = `git ls-files`.split("\n")
  gem.test_files      = gem.files.grep(%r{^(test|spec|features)/})
  gem.bindir          = "exe"
  gem.executables     = gem.files.grep(%r{^exe/}).map{ |f| File.basename(f) }
  gem.add_runtime_dependency 'taglib-ruby', '>= 0.5.0'
  gem.add_runtime_dependency "docopt", ">= 0.6.1"
  gem.homepage        = 'https://github.com/marcransome/Spfy'
  gem.license         = 'GPL-3'
end
