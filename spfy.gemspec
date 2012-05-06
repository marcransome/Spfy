#
#  spfy.gemspec
#  Spfy ("spiffy")
#
#  Copyright (c) 2012, Marc Ransome <marc.ransome@fidgetbox.co.uk>
#
#  This file is part of Spfy.
#
#  Spfy is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  Spfy is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with Spfy.  If not, see <http://www.gnu.org/licenses/>.

Gem::Specification.new do |s|
	s.name			= 'spfy'
	s.version		= '0.1.5'
	s.date			= '2012-05-06'
	s.summary		= 'XSPF playlist generator'
	s.description	= 'Spfy is a simple command-line tool for generating XSPF playlists from metadata stored in several popular audio formats.'
	s.authors		= ["Marc Ransome"]
	s.email			= 'marc.ransome@fidgetbox.co.uk'
	s.files			= `git ls-files`.split("\n")
	s.executables		<< 'spfy' 
	s.add_runtime_dependency 'taglib-ruby', '>= 0.5.0'
	s.homepage		= 'http://github.com/marcransome/spfy'
end