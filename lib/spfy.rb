require "taglib"
require 'tilt'
require 'pathname'
require 'time'

# Create XSPF playlist files
module Spfy

  # Locations of the ERB templates
  TEMPLATES = Pathname(__dir__).join("templates")

  # Produces the track entity
  # @see http://xspf.org/xspf-v1.html#rfc.section.4.1.1.2.14.1.1
  class Track
    def initialize path, options: {}
      @path = Pathname(path).expand_path
      @template = Tilt::ERBTemplate.new(TEMPLATES.join("track.xml.erb"))
      @processed = false
      @available_tags = [:location, :album, :artist, :comment, :genre, :title, :trackNum, :year]
      process
    end

    # The file path
    attr_reader :path
    alias_method :location, :path

    # The targeted sub-elements
    attr_accessor :album, :artist, :comment, :genre, :title, :trackNum, :year


    # For a block {|name,tag| ... }
    # @yield [name,tag] Yield the element name and its contents.
    def each_tag skip_nils=true
      return enum_for(:each_tag) unless block_given?
      @available_tags.each do |tag|
        contents = self.send(tag)
        if skip_nils and (
           contents.nil? or 
           (contents.respond_to?(:empty?) and contents.empty?)
          )
          next
        end
        yield tag, contents
      end
    end


    # @private
    # Process the options into a track entity.
    # Calls TagLib
    def process refresh=false
      if refresh or @processed == false
        TagLib::FileRef.open(@path.to_path) do |fileref|  
          tags = fileref.tag
  
          next if tags.nil? # skip files with no tags

          @album    = tags.album
          @artist   = tags.artist
          @comment  = tags.comment
          @genre    = tags.genre
          @title    = tags.title
          @trackNum = tags.track
          @year     = tags.year
        end
        @processed = true
      end
    end


    # The renderer
    # @return [String]
    def to_xml
      process
      @template.render(self)
    end
  end


  # Produces the playlist entity
  # @see http://xspf.org/xspf-v1.html#rfc.section.4.1.1
  class Playlist

    def initialize options
      set_traps_for_signals
      @options = options
      @files = []
      @template = Tilt::ERBTemplate.new(TEMPLATES.join("playlist.xml.erb"))
      parse @options
    end

    attr_reader :creator, :title, :options, :paths

    # @see http://xspf.org/xspf-v1.html#rfc.section.4.1.1.2.3
    def annotation
      @annotation
    end


    # @see http://xspf.org/xspf-v1.html#rfc.section.4.1.1.2.8
    def date
      Time.now.iso8601
    end


    # @private
    # The option parser
    # spfy here there and everywhere
    # {
    #   "--help"        =>  false,
    #   "--output"      =>  nil,
    #   "--title"       =>  nil,
    #   "--creator"     =>  nil,
    #   "--date"        =>  nil,
    #   "--annotation"  =>  nil,
    #   "--no-location" =>  false,
    #   "--no-title"    =>  false,
    #   "--no-artist"   =>  false,
    #   "--no-album"    =>  false,
    #   "--no-tracknum" =>  false,
    #   "--max-tracks"  =>  nil,
    #   "PATHS"=>["spec/support/fixtures/albums/mp4/mp4.m4a"],
    #   "--version"     =>  false
    # }
    def parse options
      @paths = (options.fetch "PATHS", []).map{|path| Pathname(path.sub /^~/, ENV["HOME"]) }
      return if @paths.empty?
      @title = if options["--title"]
        options["--title"]
      else
        if @paths.first.directory?
          @paths.first.basename
        else
          @paths.first.parent.basename
        end
      end
      @creator = options["--creator"] || ENV["USER"]
      @annotation = options["--annotation"] || "Created with Spfy.rb"
      @noes = options.select{|k,v| k =~ /^\-\-no\-/ and v }
      #@max_tracks = @option["--max-tracks"]
    end


    # @private
    # For interruptions
    def set_traps_for_signals
      trap(:SIGINT) do
        warn "  Received Ctrl+c"
        # cleanup
        exit 0
      end
    end


    # Render the playlist and any tracks.
    def to_xml
      return "" if @paths.empty?
      #catch :MaxTracksReached {
      @template.render(self) do
        mapped = []
        @paths.each { |path|
          if path.directory?
            path.find do |pn|
              if pn.directory?
                pn.basename.to_s[0] == '.' ?
                  Find.prune :
                  next
              else
                mapped << Spfy::Track.new(pn)
              end
            end
          else
            mapped << Spfy::Track.new(path)
          end
        }
        mapped.map(&:to_xml).join("\n")
      end
      #}
    end

  end
end