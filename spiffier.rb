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
	
		opts = OptionParser.new do |opts|
			opts.banner = "Usage: " + File.basename(__FILE__) + " [options] [source]"
			
			opts.separator ""
			opts.separator "Output:"
			
			opts.on("-o", "--output FILE", "File to output XSPF data to") do |out|
				options.output << out
			end
			
			opts.on("-t", "--title", "Include track title in output") do
				options.title = true
			end
			
			opts.on("-a", "--artist", "Include artist name in output") do
				options.artist = true
			end
			
			opts.on("-l", "--album", "Include album name in output") do
				options.album = true
			end
			
			opts.on("-n", "--tracknum", "Include track number in output") do
				options.tracknum = true
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
		
		# return the options array
		options
		
	end # def self.parse(args)
	
end # class OptionReader

class XspfGenerator

	def self.generate(file)
	
	end

end # class XspfGenerator

begin
	# test for zero arguments
	if ARGV.empty? then
		puts "Try " + File.basename(__FILE__) + " --help for available options."
		exit
	end
	
	# parse command-line arguments
	options = OptionReader.parse(ARGV)
	
rescue OptionParser::InvalidOption => t
	puts t
	puts "Try " + File.basename(__FILE__) + " --help for available options."
	exit
rescue OptionParser::MissingArgument => m
	puts m
	puts "Try " + File.basename(__FILE__) + " --help for available options."
	exit
end