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
