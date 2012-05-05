#!/usr/bin/env ruby

require 'optparse'
require 'ostruct'

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
			optparser.banner = "Usage: test.rb [options] [music dir]"
			
			optparser.separator ""
			optparser.separator "Output:"
			
			optparser.on("-o", "--output FILE", "test") do |out|		
			
			#VALIDATE FILE HERE
			
				options.output << out
			end
			
			optparser.on("-t", "--title", "Include title where availale") do
				options.title = true
				puts "title:" + options.title.to_s
			end
			
			optparser.on("-a", "--artist", "Include artist name where availale") do
				options.artist = true
				puts "artist:" + options.artist.to_s
			end
			
			optparser.on("-l", "--album", "Include album name where availale") do
				options.album = true
				puts "album:" + options.album.to_s
			end
			
			optparser.on("-n", "--tracknum", "Include track number where availale") do
				options.tracknum = true
				puts "tracknum:" + options.tracknum.to_s
			end
			
			optparser.separator ""
			optparser.separator "Common options:"
			
			optparser.on("-v", "--verbose", "Verbose program output") do
				puts tst
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
