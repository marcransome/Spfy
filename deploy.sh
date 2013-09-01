#!/bin/bash
#
#  deploy.sh
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
#

version_from_gemspec=$( grep 's.version' spfy.gemspec | cut -c 20-24 )
gem_file="spfy-$version_from_gemspec.gem"

echo "Removing outdated files.."
rm *.gem

echo "Building gem.."
gem build spfy.gemspec

echo "Uploading gem.."
gem push $gem_file
