#Spfy ("spiffy")

##Overview
**Spfy** is a command-line tool for generating [XSPF](http://xspf.org/) playlists from metadata stored in several popular audio formats and is developed entirely in [Ruby](http://www.ruby-lang.org/).  It takes one or more local directory paths as input, extracts metadata tags from any audio files that it encounters, and generates a valid XSPF playlist.

##Prerequisites
A working Ruby installation (version 1.9 or greater) is required for Spfy to work, but this is outside the scope of this guide.  For more information refer to the [official installation procedure](http://www.ruby-lang.org/en/downloads/).

[TagLib](http://developer.kde.org/~wheeler/taglib.html) is also required.  Follow the steps below (taken from the [taglib-ruby installation guide](http://robinst.github.com/taglib-ruby/)) to install the necessary files for your respective system type:

| System:       |  Command:                          |
|---------------|------------------------------------|
| Debian/Ubuntu | `sudo apt-get install libtag1-dev` |
| Fedora/RHEL   | `sudo yum install taglib-devel`    |
| Brew          | `brew install taglib`              |
| MacPorts      | `sudo port install taglib`         |

##Installation
With the prerequisites above taken care of Spfy can be installed with the following command:

	$ gem install spfy

##Using Spfy
By default, Spfy will output a formatted XSPF playlist to the standard output stream that will include _location_, _title_, _creator_, _album_, and _trackNum_ elements for each audio file where available.

The general syntax for Spfy is `spfy [options] dir1 ... dirN`, where _dir1 ... dirN_ is one or more paths to directories containing audio files.

For example:

	$ spfy ~/music
	
..will produce the following output (where ~/music contains one audio file with valid metadata):

	<?xml version="1.0" encoding="UTF-8"?>
	<playlist version="1" xmlns="http://xspf.org/ns/0/">
		<trackList>
			<track>
				<location>file:///Users/spfy/music/03%20A%20Stitch%20In%20Time.mp3</location>
				<title>A Stitch In Time</title>
				<creator>The Smashing Pumpkins</creator>
				<album>Teargarden by Kaleidyscope</album>
				<trackNum>3</trackNum>
			</track>
		</trackList>
	</playlist>
	
Spfy supports multiple directory paths (e.g. `spfy /dir1 /dir2`) and traverses each directory recursively by default.  Unsupported files and empty directories in a directory tree are silently ignored and will not impact Spfy's output.

Command-line arguments allow you to control which elements Spfy outputs:

    -f, --no-location                Suppress file location output
    -t, --no-title                   Suppress track title in output
    -a, --no-artist                  Suppress artist name in output
    -l, --no-album                   Suppress album name in output
    -n, --no-tracknum                Suppress track number in output

For additional options use `spfy --help`.

##License
Spfy is free software, and you are welcome to redistribute it under certain conditions.  See the [GNU General Public License](http://www.gnu.org/licenses/gpl.html) for more details.

##Acknowledgments
Spfy uses the following third party software components:
 
* [taglib-ruby](http://robinst.github.com/taglib-ruby/) by Robin Stocker

##Comments or suggestions?
Email me at [marc.ransome@fidgetbox.co.uk](marc.ransome@fidgetbox.co.uk) with bug reports, feature requests or general comments and follow [@marcransome](http://www.twitter.com/marcransome) for updates.
