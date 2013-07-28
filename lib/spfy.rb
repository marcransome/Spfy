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
#

require "spfy/optionreader"
require "optparse"
require "ostruct"
require "taglib"
require "find"
require "uri"

class Spfy
  
  VERSION = "1.0.0"
  USAGE = "Use `#{File.basename($0)} --help` for available options."
    
  @xml_tags = {
    :header =>          "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"\
                        "<playlist version=\"1\" xmlns=\"http://xspf.org/ns/0/\">\n"\
                        "\t<trackList>\n",
    :footer =>          "\t</trackList>\n</playlist>\n",              
    :title_start =>     "\t\t\t<title>",
    :title_end =>       "</title>\n",
    :artist_start =>   "\t\t\t<creator>",
    :artist_end =>     "</creator>\n",
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
    @tracks_processed = 0

    if @options.output.any?
      puts "Generating XML..."
      capture_stdout
    end
    
    puts @xml_tags[:header]
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
    puts @xml_tags[:footer]
    
    $stdout = STDOUT if @options.output.any?
  end

  def self.xml_for_path(path)    
    TagLib::FileRef.open(path) do |fileref|  
      tags = fileref.tag
      
      next if tags.nil? # skip files with no tags
      
      puts "#{@xml_tags[:track_start]}"      
      parse_location(path)
      parse_tag(tags.title, @options.hide_title, @xml_tags[:title_start], @xml_tags[:title_end])
      parse_tag(tags.artist, @options.hide_artist, @xml_tags[:artist_start], @xml_tags[:artist_end])
      parse_tag(tags.album, @options.hide_album, @xml_tags[:album_start], @xml_tags[:album_end])
      parse_track_num(tags.track)
      puts "#{@xml_tags[:track_end]}"
      
      @tracks_processed += 1
      throw :MaxTracksReached if @options.tracks_to_process[0].to_i > 0 and @tracks_processed == @options.tracks_to_process[0].to_i
    end
  end
  
  def self.parse_location(path)
    if !@options.hide_location
      encoded_path = URI.escape(path).sub("%5C", "/") # percent encode string for local path
      puts "#{@xml_tags[:location_start]}#{encoded_path}#{@xml_tags[:location_end]}"
    end
  end
  
  def self.parse_tag(tag, suppress_output, start_xml, end_xml)
    if !tag.nil? and !suppress_output
      puts "#{start_xml}#{tag}#{end_xml}"      
    end
  end
  
  def self.parse_track_num(track_num)
    if !@options.hide_tracknum and !track_num.nil?
      if track_num > 0
        puts "#{@xml_tags[:track_num_start]}#{track_num}#{@xml_tags[:track_num_end]}"
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
  private_class_method :xml_for_path, :parse_location, :parse_tag, :parse_track_num, :exit_with_message, :exit_with_banner, :capture_stdout
end
