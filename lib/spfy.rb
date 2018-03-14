require "taglib"
require 'tilt'
require 'pathname'
require 'time'
require 'addressable/uri'

# Create XSPF playlist files
module Spfy

  # For tagging all exceptions that come through this library.
  module Error; end


  # Locations of the ERB templates
  TEMPLATES = Pathname(__dir__).join("templates")

  # Produces the track entity
  # @see http://xspf.org/xspf-v1.html#rfc.section.4.1.1.2.14.1.1
  class Track

    # The XSPF tags being targeted
    XSPF_TAGS = [:location, :album, :artist, :comment, :genre, :title, :trackNum, :year].freeze

    # The translation of XSPF tags and Taglib tags
    XSPF_TO_TAGLIB = {
      :album    => :album,
      :artist   => :artist,
      :comment  => :comment,
      :genre    => :genre,
      :title    => :title,
      :trackNum => :track,
      :year     => :year,
    }.freeze


    # @param [String,Pathname] path The location of the track.
    # @param [Hash] options
    # @api public
    # @example
    #   Spfy::Track.new(pn, options: @options)
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
        @location = Addressable::URI.join('file:///', Addressable::URI.escape(path.to_path) )
        @data.location = @location
      end

      process
    end


    # If there's a way to do dynamic delegation using Forwadable
    # I don't know what it is. Hence this.
    # @api private
    # @see https://ruby-doc.org/core-2.5.0/BasicObject.html#method-i-method_missing
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
    # @api public
    # @return [TrueClass]
    # @see https://ruby-doc.org/core-2.5.0/Object.html#method-i-respond_to_missing-3F
    def respond_to_missing?(name, *)
      if @available_tags.include? name.to_sym
        true
      else
        super
      end
    end


    # Parse the options, mainly to find which ones were --no-
    # @api private
    # @return [<String>] Doesn't matter, it's held in the @noes instance var.
    def parse options
      @noes = options.each_with_object([]){|(k,v), obj|
                if k =~ /^\-\-no\-/ and v
                  obj << k.match(/^\-\-no\-(?<name>\w+)$/)[:name].to_sym
                end
                obj
              }
    end


    # The file path
    # @return [Pathname]
    # @api public
    attr_reader :path


    # The available tags after the options have been parsed
    # @return [<String>]
    # @api public
    attr_reader :available_tags


    # A data object that holds the taglib data in XSPF format
    # @return [Struct]
    # @api semipublic
    attr_reader :data


    # Process the options into a track entity.
    # Calls TagLib
    # @api private
    def process refresh=false
      if refresh or @processed == false
        TagLib::FileRef.open(@path.to_path) do |fileref|
          tags = fileref.tag

          unless tags.nil? # skip files with no tags
            XSPF_TO_TAGLIB.select{|k,v| available_tags.include? k }
            .each do |xspf,tagl|
              @data.send "#{xspf}=", tags.respond_to?(:strip) ? tags.send(tagl).strip : tags.send(tagl)
            end
          end
        end

        @processed = true
      end
    end


    # For a block {|name,tag| ... }
    # @yield [name,tag] Yield the element name and its contents.
    # @api public
    # @example
    #   # In ERB
    #   <% each_tag do |name,tag| %><%= "<#{name}>#{tag}</#{name}>\n" %>
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
    # @api public
    def to_xml
      process
      @template.render(self)
    end
  end


  # Produces the playlist entity
  # @see http://xspf.org/xspf-v1.html#rfc.section.4.1.1
  # @api public
  class Playlist

    # @api public
    # @example
    #   playlist = Spfy::Playlist.new options
    def initialize options
      set_traps_for_signals
      @options = options.dup
      @files = []
      @template = Tilt::ERBTemplate.new(TEMPLATES.join("playlist.xml.erb"))
      parse @options
    end


    # @see http://xspf.org/xspf-v1.html#rfc.section.4.1.1.2.2
    # @return [String]
    attr_reader :creator

    # @see http://xspf.org/xspf-v1.html#rfc.section.4.1.1.2.2
    # @return [String]
    attr_reader :title


    # @return [Hash] The options hash passed in.
    attr_reader :options

    # The paths that will be searched for files.
    # @return [<Pathname>]
    attr_reader :paths


    # @see http://xspf.org/xspf-v1.html#rfc.section.4.1.1.2.3
    # @api public
    # @return [String]
    def annotation
      @annotation
    end


    # @see http://xspf.org/xspf-v1.html#rfc.section.4.1.1.2.8
    # @api public
    # @return [String] Time now formatted as an ISO8601 date.
    def date
      Time.now.iso8601
    end


    # Parse the options further to set needed instance variables.
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
    # @api private
    # @return [Hash] Ignore the return value, this is a side-effect, it sets several instance variables
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
      @max_tracks = options["--max-tracks"] && options["--max-tracks"].to_i
      options
    end


    # For interruptions
    # @api private
    # @return There is no return value, it's a side-effect
    def set_traps_for_signals
      trap(:SIGINT) do
        warn "  Received Ctrl+c"
        # cleanup
        exit 0
      end
    end


    # Render the playlist and any tracks.
    # @api public
    # @example
    #   playlist.to_xml
    # @return [String] XML output
    def to_xml
      return "" if @paths.empty?
      mapped = []
      catch(:MaxTracksReached){
        @paths.each do |path|
          if !path.exist?
            warn "#{path.to_path} does not exist"
            next
          end
          if path.directory?
            path.find do |pn|
              if pn.directory?
                pn.basename.to_s[0] == '.' ?
                  Find.prune :
                  next
              else
                mapped << Spfy::Track.new(pn, options: @options)
                throw :MaxTracksReached if @max_tracks and mapped.size >= @max_tracks
              end
            end
          else
            mapped << Spfy::Track.new(path, options: @options)
            throw :MaxTracksReached if @max_tracks and mapped.size >= @max_tracks
          end
        end
      }
      if mapped.size.zero?
        fail RuntimeError, "No tracks found in #{@paths.map(&:to_path).join(' or ')}"
      end
      @template.render(self) do
        mapped.map(&:to_xml).join("\n")
      end

    rescue Spfy::Error
      raise
    rescue => error
      # Tag any exceptions coming through this library
      error.extend(Spfy::Error)
      raise
    end
  end
end