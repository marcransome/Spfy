#
#  spfy.rb
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

require "spfy/optionreader"
require "optparse"
require "ostruct"
require "taglib"
require "find"
require "uri"

class Spfy
  
  VERSION = "0.3.1"
  USAGE = "Use `#{File.basename($0)} --help` for available options."
    
  @xspf_tags = {
    :header =>          "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"\
                        "<playlist version=\"1\" xmlns=\"http://xspf.org/ns/0/\">\n"\
                        "\t<trackList>\n",
    :footer =>          "\t</trackList>\n</playlist>\n",              
    :title_start =>     "\t\t\t<title>",
    :title_end =>       "</title>\n",
    :creator_start =>   "\t\t\t<creator>",
    :creator_end =>     "</creator>\n",
    :album_start =>     "\t\t\t<album>",
    :album_end =>       "</album>\n",
    :location_start =>  "\t\t\t<location>file://",
    :location_end =>    "</location>\n",
    :track_start =>     "\t\t<track>\n",
    :track_end =>       "\t\t</track>\n",
    :track_num_start => "\t\t\t<trackNum>",
    :track_num_end =>   "</trackNum>\n"
  }
  
  def self.parse_args
    begin
      # test for zero arguments
      if ARGV.empty? then
        exit_with_banner
      end
      
      # parse command-line arguments
      @options = OptionReader.parse(ARGV)
      
      # test for zero source paths
      if @options.dirs.empty?
        exit_with_message("No source path(s) specified.")
      end
      
    rescue OptionParser::InvalidOption, OptionParser::MissingArgument => error
      exit_with_message(error.to_s.capitalize)
    end
  end
  
  def self.generate_xml

    if @options.output.any?
      puts "Generating XML..."
      capture_stdout
    end
    
    puts @xspf_tags[:header]
    @tracks_processed = 0
    
    @options.dirs.each do |dir|
      catch :MaxTracksReached do
        begin
          Find.find(dir) do |path|
            xml_for_path(path)
          end
        rescue Interrupt
          abort("\nCancelled, exiting..")
        end
      end
    end
    puts @xspf_tags[:footer]
    
    $stdout = STDOUT if @options.output.any?
  end

  def self.xml_for_path(path)    
    TagLib::FileRef.open(path) do |fileref|  
      tag = fileref.tag
      
      next if tag.nil? # skip files with no tags
      
      puts "#{@xspf_tags[:track_start]}"      
      parse_location(tag, path)
      parse_title(tag)
      parse_creator(tag)
      parse_album(tag)
      parse_track_num(tag)
      puts "#{@xspf_tags[:track_end]}"
      
      @tracks_processed += 1
      throw :MaxTracksReached if @options.tracks_to_process[0].to_i > 0 and @tracks_processed == @options.tracks_to_process[0].to_i
    end
  end
  
  def self.parse_location(tag, path)
    if !@options.hide_location
      encoded_path = URI.escape(path).sub("%5C", "/") # percent encode string for local path
      puts "#{@xspf_tags[:location_start]}#{encoded_path}#{@xspf_tags[:location_end]}"
    end
  end
  
  def self.parse_title(tag)
    if !@options.hide_title and !tag.title.nil?
      puts "#{@xspf_tags[:title_start]}#{tag.title}#{@xspf_tags[:title_end]}"      
    end
  end
  
  def self.parse_creator(tag)
    if !@options.hide_artist and !tag.artist.nil?
      puts "#{@xspf_tags[:creator_start]}#{tag.artist}#{@xspf_tags[:creator_end]}"
    end
  end
  
  def self.parse_album(tag)
    if !@options.hide_album and !tag.album.nil?
      puts "#{@xspf_tags[:album_start]}#{tag.album}#{@xspf_tags[:album_end]}"
    end
  end
  
  def self.parse_track_num(tag)
    if !@options.hide_tracknum and !tag.track.nil?
      if tag.track > 0
        puts "#{@xspf_tags[:track_num_start]}#{tag.track}#{@xspf_tags[:track_num_end]}"
      end
    end
  end

  def self.exit_with_message(message)
    puts message if message
    exit_with_banner
  end
  
  def self.exit_with_banner
    puts USAGE
    exit
  end
    
  def self.capture_stdout
    $stdout = File.open(@options.output[0], "w")
  end
  private_class_method :xml_for_path, :parse_location, :parse_title, :parse_creator, :parse_album, :parse_track_num, :exit_with_message, :exit_with_banner, :capture_stdout
end
