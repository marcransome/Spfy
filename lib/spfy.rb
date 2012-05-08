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
require 'find'
require 'uri'

$spfy_version = "0.1.9"

# The main Spfy class
class Spfy

	##
	# Starts the XSPF generator.
	#
	def self.generate

		# start processing command line arguments
		begin
		
			# short usage banner
			simple_usage = "Use `#{File.basename($0)} --help` for available options."
		
			# test for zero arguments
			if ARGV.empty? then
				puts simple_usage
				exit
			end
			
			# parse command-line arguments
			options = OptionReader.parse(ARGV)
			
			# dirs for traversing
			dirs = options.dirs
			
			# test for zero source paths
			if dirs.empty?
				puts "No source path specified."
				puts simple_usage
				exit
			end
			
		rescue OptionParser::InvalidOption => t
			puts t
			puts simple_usage
			exit
		rescue OptionParser::MissingArgument => m
			puts m
			puts simple_usage
			exit
		end
		
		# start processing source paths
		if options.output.any?
			# source path(s) provided, output should be to disk
			
			# open output file for writing
			begin
				xmlFile = File.open(options.output[0], "w")
			rescue
				puts "Unable to open output file for writing."
				puts simple_usage
				exit
			end
			
			print "Generating XML.."

			# write XSPF header
			xmlFile.write("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")
			xmlFile.write("<playlist version=\"1\" xmlns=\"http://xspf.org/ns/0/\">\n")
			xmlFile.write("\t<trackList>\n")
			
			# track count for track limit option
			tracks_processed = 0
			
			# repeat for each source dir argument
			dirs.each do |dir|
	
				begin
					
					# repeat for each file recursively
					Find.find(dir) do |path|
					
						TagLib::FileRef.open(path) do |fileref|
							
							tag = fileref.tag
							
							# skip files with no tags
							next if tag.nil?
							
							# write track metadata
							xmlFile.write("\t\t<track>\n")
							
							if !options.hide_location
								# generate a percent encoded string from the local path
								encoded_path = URI.escape(path)
								xmlFile.write("\t\t\t<location>file://#{encoded_path}</location>\n")
							end
							
							xmlFile.write("\t\t\t<title>#{tag.title}</title>\n") if !options.hide_title and !tag.title.nil?
							xmlFile.write("\t\t\t<creator>#{tag.artist}</creator>\n") if !options.hide_artist and !tag.artist.nil?
							xmlFile.write("\t\t\t<album>#{tag.album}</album>\n") if !options.hide_album and !tag.album.nil?
							
							if !options.hide_tracknum and !tag.track.nil?
								if tag.track > 0
									xmlFile.write("\t\t\t<trackNum>#{tag.track}</trackNum>\n")
								end
							end
							
							xmlFile.write("\t\t</track>\n")
							
							# increment our track processed count
							tracks_processed += 1
							
							# if a maximum number track numbe has been set, test whether we have reached the limit
							if options.tracks_to_process[0].to_i > 0 and tracks_processed == options.tracks_to_process[0].to_i 
								# write XSPF footer
								xmlFile.write("\t</trackList>\n")
								xmlFile.write("</playlist>\n")
								xmlFile.close
								print " success\n"
								exit
							end
						end
					end
				rescue Interrupt
					abort("\nCancelled, exiting..")
				end # begin
			end # dirs.each do |dir|
			
			# write XSPF footer
			xmlFile.write("\t</trackList>\n")
			xmlFile.write("</playlist>\n")
			
			xmlFile.close
			
			print " success\n"
			
		else
			# no source path(s) provided, output to stdout
			
			# write XSPF header
			puts "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
			puts "<playlist version=\"1\" xmlns=\"http://xspf.org/ns/0/\">\n"
			puts "\t<trackList>\n"
			
			# track count for track limit option
			tracks_processed = 0
			
			# repeat for each source dir argument
			dirs.each do |dir|

				begin
				
					# repeat for each file recursively
					Find.find(dir) do |path|
					
						TagLib::FileRef.open(path) do |fileref|
						
							tag = fileref.tag
		
							# skip files with no tags
							next if tag.nil?
							
							# output track metadata
							puts "\t\t<track>\n"
							
							if !options.hide_location
								encoded_path = URI.escape(path)
								puts "\t\t\t<location>file://#{encoded_path}</location>\n"
							end
							
							puts "\t\t\t<title>#{tag.title}</title>\n" if !options.hide_title and !tag.title.nil?
							puts "\t\t\t<creator>#{tag.artist}</creator>\n" if !options.hide_artist and !tag.artist.nil?
							puts "\t\t\t<album>#{tag.album}</album>\n" if !options.hide_album and !tag.album.nil?
							
							if !options.hide_tracknum and !tag.track.nil?
								if tag.track > 0
									puts "\t\t\t<trackNum>#{tag.track}</trackNum>\n"
								end
							end
							
							puts "\t\t</track>\n"
							
							# increment our track processed count
							tracks_processed += 1

							# if a maximum number track numbe has been set, test whether we have reached the limit
							if options.tracks_to_process[0].to_i > 0 and tracks_processed == options.tracks_to_process[0].to_i 
								# output XSPF footer
								puts "\t</trackList>\n"
								puts "</playlist>\n"
								exit
							end
						end
					end
				rescue Interrupt
					abort("\nCancelled, exiting..")
				end # begin
			end # dirs.each do |dir|
			
			# write XSPF footer
			puts "\t</trackList>\n"
			puts "</playlist>\n"
		end

	end # def self.generate

end # class Spyf
