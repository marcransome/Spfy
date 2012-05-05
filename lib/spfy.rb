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

require "optparse"
require "ostruct"
require "taglib"

$version = "0.1"
$dirs = []

class Spfy

end

class OptionReader

	def self.parse(args)
	
		options = OpenStruct.new
		options.output = []
		options.verbose = false
		options.hide_title = false
		options.hide_artist = false
		options.hide_album = false
		options.hide_tracknum = false
	
		opts = OptionParser.new do |opts|
			opts.banner = "Usage: " + File.basename(__FILE__) + " [options] [source]"
			
			opts.separator ""
			opts.separator "Output:"
			
			opts.on("-o", "--output FILE", "File to output XSPF data to") do |out|
				options.output << out
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
			
			opts.separator ""
			opts.separator "Common options:"
			
			opts.on("-v", "--version", "Display version information") do
				puts "Spiffier #{$version} Copyright (c) 2012 Marc Ransome <marc.ransome@fidgetbox.co.uk>"
				puts "This program comes with ABSOLUTELY NO WARRANTY, use it at your own risk."
				puts "This is free software, and you are welcome to redistribute it under"
				puts "certain conditions; type `" + File.basename(__FILE__, ".*") + " --license' for details."
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
				$dirs << dir
			end
			
		end

		# return the options array
		options
		
	end # def self.parse(args)
	
end # class OptionReader

class Spfy

	def self.generate
	
		#
		# Read command-line arguments
		#
		begin
		
			# test for zero arguments
			if ARGV.empty? then
				puts "Try " + File.basename(__FILE__) + " --help for available options."
				exit
			end
			
			# parse command-line arguments
			options = OptionReader.parse(ARGV)
			
			# test for zero source paths
			if $dirs.empty?
				puts "No source path specified."
				puts "Try " + File.basename(__FILE__) + " --help for available options."
				exit
			end
			
		rescue OptionParser::InvalidOption => t
			puts t
			puts "Try " + File.basename(__FILE__) + " --help for available options."
			exit
		rescue OptionParser::MissingArgument => m
			puts m
			puts "Try " + File.basename(__FILE__) + " --help for available options."
			exit
		end
		
		#
		# Process valid paths
		#
		begin
			if options.output.any?
				
				# test whether there is an option for data to output
				if options.hide_title and options.hide_artist and options.hide_album
					
					# all data has been suppressed, report to user
					puts "All tags suppressed, no XML file created."
					exit
				end
			
				xmlFile = File.open(options.output[0], "w")
				
				print "Generating XML.."
				
				xmlFile.write("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")
				xmlFile.write("<playlist version=\"1\" xmlns=\"http:#xspf.org/ns/0/\">\n")
				xmlFile.write("\t<trackList>\n")
				
				Dir.foreach($dirs[0]).sort.each do |file|
					next if file == '.' or file == '..' or
					next if file.start_with? '.'
					
					begin
						TagLib::FileRef.open($dirs[0] + "/" + file) do |fileref|
		
							tag = fileref.tag
							
							# skip files with no tags
							next if tag.title.empty? and tag.artist.empty? and tag.album.empty?
							
							xmlFile.write("\t\t<track>\n")
							#xmlFile.write("\t\t\t<location>http:##{host}#{musicDir}/#{file}</location>\n")
							xmlFile.write("\t\t\t<title>#{tag.title}</title>\n") if !options.hide_title and !tag.title.empty?
							xmlFile.write("\t\t\t<creator>#{tag.artist}</creator>\n") if !options.hide_artist and !tag.artist.empty?
							xmlFile.write("\t\t\t<album>#{tag.album}</album>\n") if !options.hide_album and !tag.album.empty?
							xmlFile.write("\t\t</track>\n")
							
						end
					rescue Exception => e
						next
					end
				end
				
				xmlFile.write("\t</trackList>\n")
				xmlFile.write("</playlist>\n")
				xmlFile.close
				
				print " success\n"
			else		
				puts "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
				puts "<playlist version=\"1\" xmlns=\"http:#xspf.org/ns/0/\">\n"
				puts "\t<trackList>\n"
				
				Dir.foreach($dirs[0]).sort.each do |file|
					next if file == '.' or file == '..' or
					next if file.start_with? '.'
					
					begin
						TagLib::FileRef.open($dirs[0] + "/" + file) do |fileref|
						
							tag = fileref.tag
		
							# skip files with no tags
							next if tag.title.empty? and tag.artist.empty? and tag.album.empty?
		
							puts "\t\t<track>\n"
							#xmlFile.write("\t\t\t<location>http:##{host}#{musicDir}/#{file}</location>\n")
							puts "\t\t\t<title>#{tag.title}</title>\n"
							puts "\t\t\t<creator>#{tag.artist}</creator>\n"
							puts "\t\t\t<album>#{tag.album}</album>\n"
							puts "\t\t</track>\n"
							
						end
					rescue Exception => e
						next
					end
				end
				
				puts "\t</trackList>\n"
				puts "</playlist>\n"
			end
			
		rescue SystemExit, Interrupt
			abort("Cancelled, exiting..")
		rescue Exception => e	
			abort("Exiting.. (#{e})")
		end

	end # self.generate

end # class Spfy

