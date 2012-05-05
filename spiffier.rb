#!/usr/bin/env ruby

require "optparse"
require "ostruct"
require "taglib"

$version = "0.1"
$dirs = []

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

class XspfGenerator

	def self.generate(file)
	
	end

end # class XspfGenerator

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
		xmlFile = File.open(options.output[0], "w")
		
		print "Generating XML.."
		
		xmlFile.write("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")
		xmlFile.write("<playlist version=\"1\" xmlns=\"http://xspf.org/ns/0/\">\n")
		xmlFile.write("\t<trackList>\n")
		
		Dir.foreach($dirs[0]).sort.each do |file|
			next if file == '.' or file == '..' or
			next if file.start_with? '.'
			
			begin
				TagLib::FileRef.open($dirs[0] + "/" + file) do |fileref|
				
					tag = fileref.tag
					
					xmlFile.write("\t\t<track>\n")
					#xmlFile.write("\t\t\t<location>http://#{host}#{musicDir}/#{file}</location>\n")
					xmlFile.write("\t\t\t<title>#{tag.title}</title>\n")
					xmlFile.write("\t\t\t<creator>#{tag.artist}</creator>\n")
					xmlFile.write("\t\t\t<album>#{tag.album}</album>\n")
					xmlFile.write("\t\t</track>\n")
					
				end
			rescue Exception => e
				puts "ignored: " + $dirs[0] + "/" + file
				next
			end
		end
		
		xmlFile.write("\t</trackList>\n")
		xmlFile.write("</playlist>\n")
		xmlFile.close
		
		print " success\n"
	else		
		puts "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
		puts "<playlist version=\"1\" xmlns=\"http://xspf.org/ns/0/\">\n"
		puts "\t<trackList>\n"
		
		Dir.foreach($dirs[0]).sort.each do |file|
			next if file == '.' or file == '..' or
			next if file.start_with? '.'
			
			begin
				TagLib::FileRef.open($dirs[0] + "/" + file) do |fileref|
				
					tag = fileref.tag

					puts "\t\t<track>\n"
					#xmlFile.write("\t\t\t<location>http://#{host}#{musicDir}/#{file}</location>\n")
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
		puts "Success."
	end
	
rescue SystemExit, Interrupt
	abort("\nCancelled, exiting..")
rescue Exception => e	
	abort("\nExiting.. (#{e})")
end

