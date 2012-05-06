#Spfy ("spiffy")

##Overview
**Spfy** is a command-line ruby tool for generating XSPF playlists from metadata stored in several popular audio formats.

##Installation
[TagLib](http://developer.kde.org/~wheeler/taglib.html) is required for spfy to work.  Follow the steps below (taken from the [taglib-ruby installation guide](http://robinst.github.com/taglib-ruby/)) to install the necessary files for your respective system type:

> | System:       |  Command:                          |
> |---------------|------------------------------------|
> | Debian/Ubuntu | `sudo apt-get install libtag1-dev` |
> | Fedora/RHEL   | `sudo yum install taglib-devel`    |
> | Brew          | `brew install taglib`              |
> | MacPorts      | `sudo port install taglib`         |
> 
> Windows users on Ruby 1.9 don't need that, because there is a pre-compiled binary gem available which bundles taglib.

With the prerequisites out of the way install spfy by typing:

	gem install spfy
	
##Using spfy
By default, spfy will output a formatted [XSPF](http://xspf.org/) playlist to the standard output stream that will include _title_, _artist_, and _album_ tags for each audio file where available.

The general syntax for running spfy is `spfy [options] [source]`, where _source_ is a valid path to a directory containing audio files.

For example:

	% spfy ~/music
	
..will produce the following output (where ~/music contains one audio file with valid metadata):

	<?xml version="1.0" encoding="UTF-8"?>
	<playlist version="1" xmlns="http://xspf.org/ns/0/">
		<trackList>
			<track>
				<title>A Stitch In Time</title>
				<creator>The Smashing Pumpkins</creator>
				<album>Teargarden by Kaleidyscope</album>
			</track>
		</trackList>
	</playlist>
	
Command-line arguments allow you to control what elements are present in spfy's output, as well as output directly to a file on disk:

    -o, --output FILE                File to output XSPF data to
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