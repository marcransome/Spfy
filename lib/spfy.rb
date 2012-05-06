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
#  along with Spfy.  If not, see <http:#www.gnu.org/licenses/>.

require "spfy/optionreader"
require "optparse"
require "ostruct"
require "taglib"
require 'find'
require 'uri'

$version = "0.1.3"
$dirs = []

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
			
			# test for zero source paths
			if $dirs.empty?
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
		begin
			if options.output.any?
			
				xmlFile = File.open(options.output[0], "w")
				
				print "Generating XML.."
	
				# write XSPF header
				xmlFile.write("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")
				xmlFile.write("<playlist version=\"1\" xmlns=\"http://xspf.org/ns/0/\">\n")
				xmlFile.write("\t<trackList>\n")
				
				# repeat for each source dir argument
				$dirs.each do |dir|
		
					# repeat for each file recursively
					Find.find(dir) do |path|
					
						begin
							TagLib::FileRef.open(path) do |fileref|
								
								tag = fileref.tag
								
								# skip files with no tags
								next if tag.title.empty? and tag.artist.empty? and tag.album.empty?
								
								# write track metadata
								xmlFile.write("\t\t<track>\n")
								
								if !options.hide_location
									encoded_path = URI.escape(path)
									xmlFile.write("\t\t\t<location>file://#{encoded_path}</location>\n")
								end
								
								xmlFile.write("\t\t\t<title>#{tag.title}</title>\n") if !options.hide_title and !tag.title.empty?
								xmlFile.write("\t\t\t<creator>#{tag.artist}</creator>\n") if !options.hide_artist and !tag.artist.empty?
								xmlFile.write("\t\t\t<album>#{tag.album}</album>\n") if !options.hide_album and !tag.album.empty?
								xmlFile.write("\t\t</track>\n")
							end
						rescue Exception => e
							next
						end
					end
				end
				
				# write XSPF footer
				xmlFile.write("\t</trackList>\n")
				xmlFile.write("</playlist>\n")
				
				xmlFile.close
				
				print " success\n"
				
			else		
				puts "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
				puts "<playlist version=\"1\" xmlns=\"http://xspf.org/ns/0/\">\n"
				puts "\t<trackList>\n"
				
				# repeat for each source dir argument
				$dirs.each do |dir|
				
					# repeat for each file recursively
					Find.find(dir) do |path|
					
						begin
							TagLib::FileRef.open(path) do |fileref|
							
								tag = fileref.tag
			
								# skip files with no tags
								next if tag.title.empty? and tag.artist.empty? and tag.album.empty?
			
								# output track metadata
								puts "\t\t<track>\n"
								
								if !options.hide_location
									encoded_path = URI.escape(path)
									puts "\t\t\t<location>file://#{encoded_path}</location>\n"
								end
								
								puts "\t\t\t<title>#{tag.title}</title>\n" if !options.hide_title and !tag.title.empty?
								puts "\t\t\t<creator>#{tag.artist}</creator>\n" if !options.hide_artist and !tag.artist.empty?
								puts "\t\t\t<album>#{tag.album}</album>\n" if !options.hide_album and !tag.album.empty?
								puts "\t\t</track>\n"
							end
						rescue Exception => e
							next
						end
					end
				end
				
				# write XSPF footer
				puts "\t</trackList>\n"
				puts "</playlist>\n"
			end
			
		rescue SystemExit, Interrupt
			abort("Cancelled, exiting..")
		rescue Exception => e	
			abort("Exiting.. (#{e})")
		end

	end # def self.generate

end # class Spyf
