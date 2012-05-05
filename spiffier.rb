#!/usr/bin/env ruby

require 'optparse'
require 'ostruct'

$version = "0.1"

class OptionReader

	def self.parse(args)
	
		options = OpenStruct.new
		options.output = []
		options.verbose = false
		options.title = false
		options.artist = false
		options.album = false
		options.tracknum = false
	
		optparser = OptionParser.new do |optparser|
			optparser.banner = "Usage: " + File.basename(__FILE__) + " [options] [music dir]"
			
			optparser.separator ""
			optparser.separator "Output:"
			
			optparser.on("-o", "--output FILE", "File to output XSPF data to") do |out|		
			
				#VALIDATE FILE HERE
				options.output << out
			end
			
			optparser.on("-t", "--title", "Include track title in output") do
				options.title = true
				puts "title:" + options.title.to_s
			end
			
			optparser.on("-a", "--artist", "Include artist name in output") do
				options.artist = true
				puts "artist:" + options.artist.to_s
			end
			
			optparser.on("-l", "--album", "Include album name in output") do
				options.album = true
				puts "album:" + options.album.to_s
			end
			
			optparser.on("-n", "--tracknum", "Include track number in output") do
				options.tracknum = true
				puts "tracknum:" + options.tracknum.to_s
			end
			
			optparser.separator ""
			optparser.separator "Common options:"
			
			optparser.on("-v", "--version", "Display version information") do
				puts "Spiffier #{$version} Copyright (c) 2012 Marc Ransome <marc.ransome@fidgetbox.co.uk>"
				puts "This program comes with ABSOLUTELY NO WARRANTY, use it at your own risk."
				puts "This is free software, and you are welcome to redistribute it under"
				puts "certain conditions; type `" + File.basename(__FILE__, ".*") + " --license' for details."
				exit
			end
			
			optparser.on_tail("-h", "--help", "Show this screen") do
				puts optparser
				exit
			end
		end
		
		# parse then remove the remaining arguments
		optparser.parse!(args)
		
		# test for empty output
		if options.output.empty? then
			puts "No output file was specified."
		end
		
		# return the options array
		options
		
	end # def self.parse(args)
	
end # class OptionReader

class XspfGenerator

	def self.generate(file)
	
	end

end # class XspfGenerator

options = OptionReader.parse(ARGV)
