#
#  optionreader.rb
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

class OptionReader

  def self.parse(args)
  
    options = OpenStruct.new
    options.output = []
    options.verbose = false
    options.hide_title = false
    options.hide_artist = false
    options.hide_album = false
    options.hide_location = false
    options.hide_tracknum = false
    options.dirs = []
    options.tracks_to_process = []
  
    opts = OptionParser.new do |opts|
      opts.banner = "Usage: #{File.basename($0)} [options] dir1 ... dirN"
      
      opts.separator ""      
      
      opts.separator "#{File.basename($0).capitalize} supports multiple directory paths and traverses each directory recursively."
      opts.separator "Non-audio files are ignored and will not impact #{File.basename($0)}'s output."
      
      opts.separator ""
      opts.separator "Output options:"
      
      opts.on("-o", "--output FILE", "File to output XSPF data to") do |out|
        options.output << out
      end
      
      opts.on("-f", "--no-location", "Suppress file location output") do
        options.hide_location = true
      end
      
      opts.on("-t", "--no-title", "Suppress track title in output") do
        options.hide_title = true
      end
      
      opts.on("-a", "--no-artist", "Suppress artist name in output") do
        options.hide_artist = true
      end
      
      opts.on("-l", "--no-album", "Suppress album name in output") do
        options.hide_album = true
      end
      
      opts.on("-n", "--no-tracknum", "Suppress track number in output") do
        options.hide_tracknum = true
      end
      
      opts.on("-m", "--max-tracks NUM", "Limit the output to NUM tracks") do |num|
        options.tracks_to_process << num
        options.track_limit = true
      end
      
      opts.separator ""
      opts.separator "Misc options:"
      
      opts.on("-v", "--version", "Display version information") do
        puts "#{File.basename($0).capitalize} #{Spfy::VERSION} Copyright (c) 2012 Marc Ransome <marc.ransome@fidgetbox.co.uk>"
        puts "This program comes with ABSOLUTELY NO WARRANTY, use it at your own risk."
        puts "This is free software, and you are welcome to redistribute it under"
        puts "certain conditions; see LICENSE.txt for details."
        exit
      end
      
      opts.on_tail("-h", "--help", "Show this screen") do
        puts opts
        exit
      end
    end
    
    # parse then remove the remaining arguments
    opts.parse!(args)
    
    # test leftover input for valid paths
    args.each do |dir|
    
      # add path to global dirs variable
      if File.directory?(dir)
        options.dirs << dir
      end
      
    end

    # return the options array
    options
    
  end # def self.parse(args)
  
end # class OptionReader
