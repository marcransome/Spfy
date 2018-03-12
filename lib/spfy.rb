require "taglib"
require 'tilt'
require 'pathname'
require 'time'
require 'uri'

# Create XSPF playlist files
module Spfy

  # Locations of the ERB templates
  TEMPLATES = Pathname(__dir__).join("templates")


  # Produces the track entity
  # @see http://xspf.org/xspf-v1.html#rfc.section.4.1.1.2.14.1.1
  class Track

    XSPF_TAGS = [:location, :album, :artist, :comment, :genre, :title, :trackNum, :year].freeze
    XSPF_TO_TAGLIB = {
      :album    => :album,
      :artist   => :artist,
      :comment  => :comment,
      :genre    => :genre,
      :title    => :title,
      :trackNum => :track,
      :year     => :year,
    }.freeze


    # param [String,Pathname] path The location of the track.
    # param [Hash] options
    def initialize path, options: {}
      @path = Pathname(path).expand_path
      @template = Tilt::ERBTemplate.new(TEMPLATES.join("track.xml.erb"))
      @processed = false
      @options = options.dup
      parse @options
      @available_tags = XSPF_TAGS - @noes
      @data_klass = Struct.new *@available_tags
      @data = @data_klass.new
      # @see http://xspf.org/xspf-v1.html#rfc.section.4.1.1.2.5
      if @location.nil? and @available_tags.include?(:location)
        path = @path.absolute? ? @path : @path.realpath
        @location = URI.join('file:///', URI.escape(path.to_path) )
        @data.location = @location
      end

      process
    end


    # If there's a way to do dynamic delegation using Forwadable
    # I don't know what it is. Hence this.
    def method_missing(name, *args)
      if @available_tags.include? name.to_sym
        instance_eval <<-RUBY
          def #{name}
            @data.send :#{name}
          end
        RUBY
        send name.to_sym
      else
        super
      end
    end


    # Be a good person
    def respond_to?(name, include_private = false)
      if @available_tags.include? name.to_sym
        true
      else
        super
      end
    end


    # Parse the options, mainly to find which ones were --no-
    def parse options
      @noes = options.each_with_object([]){|(k,v), obj|
                if k =~ /^\-\-no\-/ and v
                  obj << k.match(/^\-\-no\-(?<name>\w+)$/)[:name].to_sym
                end
                obj
              }
    end

    # The file path
    attr_reader :path
    attr_reader :available_tags
    attr_reader :data


    # @private
    # Process the options into a track entity.
    # Calls TagLib
    def process refresh=false
      if refresh or @processed == false
        TagLib::FileRef.open(@path.to_path) do |fileref|
          tags = fileref.tag

          unless tags.nil? # skip files with no tags
            XSPF_TO_TAGLIB.select{|k,v| available_tags.include? k }
            .each do |xspf,tagl|
              @data.send "#{xspf}=", tags.send(tagl)
            end
          end
        end

        @processed = true
      end
    end


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
      @options = options.dup
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
      @paths = (options.delete("PATHS") || []).map{|path| Pathname(path.sub /^~/, ENV["HOME"]) }
      return if @paths.empty?
      @title = if options["--title"]
        options.delete("--title")
      else
        if @paths.first.directory?
          @paths.first.basename
        else
          @paths.first.parent.basename
        end
      end
      @creator = options.delete("--creator") || ENV["USER"]
      @annotation = options.delete("--annotation") || "Created with Spfy.rb"
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
                mapped << Spfy::Track.new(pn, options: @options)
              end
            end
          else
            mapped << Spfy::Track.new(path, options: @options)
          end
        }
        mapped.map(&:to_xml).join("\n")
      end
      #}
    end

  end
end