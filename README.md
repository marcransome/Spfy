#Spfy ("spiffy")

##Overview
**Spfy** is a command-line tool for generating [XSPF](http://xspf.org/) playlists from metadata stored in several popular audio formats, and is developed entirely in [Ruby](http://www.ruby-lang.org/).  It takes one or more local directory paths as input and traverses the directory structures extracting tags from any audio files that it encounters and outputs a valid XSPF playlist, either to the standard output stream or a file on disk.

##Installation
[TagLib](http://developer.kde.org/~wheeler/taglib.html) is required for spfy to work.  Follow the steps below (taken from the [taglib-ruby installation guide](http://robinst.github.com/taglib-ruby/)) to install the necessary files for your respective system type:

> | System:       |  Command:                          |
> |---------------|------------------------------------|
> | Debian/Ubuntu | `sudo apt-get install libtag1-dev` |
> | Fedora/RHEL   | `sudo yum install taglib-devel`    |
> | Brew          | `brew install taglib`              |
> | MacPorts      | `sudo port install taglib`         |

With the prerequisites taken care of spfy can be installed with the following command:

	gem install spfy
	
##Using spfy
By default, spfy will output a formatted XSPF playlist to the standard output stream that will include _location_, _title_, _artist_, and _album_ elements for each audio file where available.

The general syntax for spfy is `spfy [options] dir1 ... dirN`, where _dir1 ... dirN_ is one or more paths to directories containing audio files.

For example:

	% spfy ~/music
	
..will produce the following output (where ~/music contains one audio file with valid metadata):

	<?xml version="1.0" encoding="UTF-8"?>
	<playlist version="1" xmlns="http://xspf.org/ns/0/">
		<trackList>
			<track>
				<location>file:///Users/spfy/music/03%20A%20Stitch%20In%20Time.mp3</location>
				<title>A Stitch In Time</title>
				<creator>The Smashing Pumpkins</creator>
				<album>Teargarden by Kaleidyscope</album>
			</track>
		</trackList>
	</playlist>
	
Spfy supports multiple directory paths (e.g. `spfy /dir1 /dir2`) and traverses each directory recursively by default.  Unsupported files and empty directories in a directory tree are silently ignored and will not impact spfy's output.

Command-line arguments allow you to control which elements spfy outputs:

    -f, --no-location                Suppress file location output
    -t, --no-title                   Suppress track title in output
    -a, --no-artist                  Suppress artist name in output
    -l, --no-album                   Suppress album name in output

For additional options use `spfy --help`.

##License
Spfy is licensed under the [GNU General Public License v3.0](http://www.gnu.org/licenses/gpl.html).

##Acknowledgments
Spfy uses the following third party software components:
 
* [taglib-ruby](http://robinst.github.com/taglib-ruby/) by Robin Stocker

##Comments or suggestions?
Feel free to contact me with bug reports, feature requests and general comments by emailing [marc.ransome@fidgetbox.co.uk](marc.ransome@fidgetbox.co.uk).

Follow [@marcransome](http://www.twitter.com/marcransome) on Twitter for the latest news.