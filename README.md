## Spfy ("spiffy") [![Code Climate](http://img.shields.io/codeclimate/github/marcransome/Spfy.svg)](https://codeclimate.com/github/marcransome/Spfy)

### Overview
**Spfy** is a command-line tool for generating [XSPF](http://xspf.org/) playlists from metadata stored in several popular audio formats and is developed entirely in [Ruby](http://www.ruby-lang.org/).  It takes one or more local directory paths as input, extracts metadata tags from any audio files that it encounters, and generates a valid XSPF playlist.

### Prerequisites
A working Ruby installation (version 2.0 or greater) is required for Spfy to work, but this is outside the scope of this guide.  For more information refer to the [official installation procedure](http://www.ruby-lang.org/en/downloads/).

[TagLib](http://developer.kde.org/~wheeler/taglib.html) is also required.  Follow the steps below (taken from the [taglib-ruby installation guide](http://robinst.github.com/taglib-ruby/)) to install the necessary files for your respective system type:

| System:       |  Command:                          |
|---------------|------------------------------------|
| Debian/Ubuntu | `sudo apt-get install libtag1-dev` |
| Fedora/RHEL   | `sudo yum install taglib-devel`    |
| Brew          | `brew install taglib`              |
| MacPorts      | `sudo port install taglib`         |
| Pkgsrc        | `(sudo) pkgin install taglib`      |

### Installation
With the prerequisites above taken care of Spfy can be installed with the following command:

	$ gem install spfy

### Using Spfy
By default, Spfy will output a formatted XSPF playlist to the standard output stream that will include _location_, _album_, _artist_, _comment_, _genre_, _title_, _trackNum_, and _year_ elements for each audio file where available.

The general syntax for Spfy is `spfy [options] dir1 ... dirN`, where _dir1 ... dirN_ is one or more paths to directories containing audio files.

For example:

    $ spfy ~/music/"Smashing Pumpkins"
	
..will produce the following output (where ~/music/Smashing\ Pumpkins contains one audio file with valid metadata):

```xml
<?xml version="1.0" encoding="UTF-8"?>
<playlist version="1" xmlns="http://xspf.org/ns/0/">
  <title>Smashing Pumpkins</title>
  <creator>bobby (or whatever your username is)</creator>
  <date>2018-03-11T06:49:16+00:00</date>
  <annotation>Created with Spfy.rb</annotation>
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
```

Spfy supports multiple directory paths (e.g. `spfy /dir1 /dir2`) and traverses each directory recursively by default.  Unsupported files and empty directories in a directory tree are silently ignored and will not impact Spfy's output. It will even take a single file as a target, or directories with sub-directories that hold files (no max depth has been set on the recursion so don't start to far up the directory tree;)

Command-line arguments allow you to control which elements Spfy outputs:

    --no-location                 Suppress file location output
    --no-title                    Suppress track title in output
    --no-artist                   Suppress artist name in output
    --no-album                    Suppress album name in output
    --no-trackNum                 Suppress track number in output - CASE SENSITIVE!

You can also control the metadata for the playlist:

    -t TITLE --title=TITLE        Playlist title
    -c CREATOR --creator=CREATOR  Playlist creator, defaults to env $USER
    -d DATE --date=DATE           Playlist creation date, defaults to now
    -a NOTE --annotation=NOTE     Playlist annotation, default: "Created with Spfy.rb"

Specify an output file:

    -o FILE --output=FILE         File to write to, otherwise output to STDOUT
    --force                       Allow the overwriting of a file.

Limit the number of tracks:

    --max-tracks NUM              Limit the output to NUM tracks

And prettify the output:

    --use-tidy                    Run the tidy command to prettify the output. 
                                  Uses `/usr/bin/command -v tidy` to find tidy and
                                   `tidy -q -i -xml` to filter through.

Although you could simply not specify an outfile and pipe through a filter of your choice to get the same effect.

For additional options use `spfy --help`.

### License
Spfy is free software, and you are welcome to redistribute it under certain conditions.  See the [GNU General Public License](http://www.gnu.org/licenses/gpl.html) for more details.


### Development

Use Bundler to install the development dependencies and then run the Rake task to copy the audio files for the specs to run against.


### Acknowledgements
Spfy uses the following third party software components:
 
* [taglib-ruby](http://robinst.github.com/taglib-ruby/) by Robin Stocker

### Contact
Email me at [marc.ransome@fidgetbox.co.uk](mailto_marc_.ransome@fidgetbox.co.uk) or tweet [@marcransome](http://www.twitter.com/marcransome).
