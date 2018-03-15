require 'spec_helper'
require_relative "../lib/spfy.rb"
require 'open3'

Albums = Fixtures.join("albums")

# Must use tidy because Haml and ERB cannot be trusted to produce
# the same data each time or between versions
def cmd str
  stdout, _= Open3.capture2("tidy -q -i -xml", stdin_data: str)
#   puts stdout
  stdout
end

describe "Track" do

  context "Given some noes" do
    Given(:path) { Albums.join("mp4/mp4.m4a") }
    context "No location" do
      Given(:options) {
        {
          "--no-location" =>  true,
          "--no-title"    =>  false,
          "--no-artist"   =>  false,
          "--no-album"    =>  false,
          "--no-tracknum" =>  false,
        }
      }
      Given(:track) { Spfy::Track.new path, options: options }
      context "the unit" do
        Then { track.instance_variable_get(:@noes) == [:location] }

        Then { track.available_tags.sort == (Spfy::Track::XSPF_TAGS - [:location]).sort }
        And { track.respond_to?(:location) == false }
        And { track.respond_to? :album }
        And { track.respond_to? :creator }
        And { track.respond_to? :annotation }
        And { track.respond_to? :title }
        And { track.respond_to? :trackNum }
        And { track.respond_to? :data }

        Then { track.data.respond_to?(:location) == false }
        And { track.data.respond_to? :album }
        And { track.data.respond_to? :creator }
        And { track.data.respond_to? :annotation }
        And { track.data.respond_to? :title }
        And { track.data.respond_to? :trackNum }

        Then { track.album == "Album" }
        And { track.creator == "Artist" }
        And { track.annotation == "Comment" }
        And { track.title == "Title" }
        And { track.trackNum == 7 }
      end
    end
    context "No title or artist" do
      Given(:options) {
        {
          "--no-location" =>  false,
          "--no-title"    =>  true,
          "--no-artist"   =>  true,
          "--no-album"    =>  false,
          "--no-tracknum" =>  false,
        }
      }
      Given(:track) { Spfy::Track.new path, options: options }
      context "the unit" do
        Then { track.instance_variable_get(:@noes).sort == [:creator,:title].sort }

        Then { track.available_tags.sort == (Spfy::Track::XSPF_TAGS - [:creator,:title]).sort }
        And { track.respond_to?(:location) }
        And { track.respond_to? :album }
        And { track.respond_to?( :creator ) == false }
        And { track.respond_to? :annotation }
        And { track.respond_to?( :title ) == false }
        And { track.respond_to? :trackNum }
        And { track.respond_to? :data }

        Then { track.data.respond_to? :location }
        And { track.data.respond_to? :album }
        And { track.data.respond_to?( :creator ) == false }
        And { track.data.respond_to? :annotation }
        And { track.data.respond_to?( :title ) == false }
        And { track.data.respond_to? :trackNum }

        Then { track.album == "Album" }
        And { track.annotation == "Comment" }
        And { track.trackNum == 7 }
      end
    end
  
  end
  
  context "Most simple case" do
    Given(:path) { Albums.join("mp4/mp4.m4a") }
    Given(:track) { Spfy::Track.new path }
    # Mung the path in the file so it works on any machine
    Given(:location) { 
      track = Albums.join("mp4/mp4.m4a").to_path
      Addressable::URI.join( "file:///", Addressable::URI.escape( track ))
    }
    Given(:xml_comparator) {
      Fixtures.join("mp4.m4a.xml")
        .read
        .sub /FIXTURE/, location.to_s
    }
    context "the unit" do
      Then { track.available_tags == Spfy::Track::XSPF_TAGS }
      And { track.respond_to? :location }
      And { track.respond_to? :album }
      And { track.respond_to? :creator }
      And { track.respond_to? :annotation }
      And { track.respond_to? :title }
      And { track.respond_to? :trackNum }
      And { track.respond_to? :data }

      Then { track.data.respond_to? :location }
      And { track.data.respond_to? :album }
      And { track.data.respond_to? :creator }
      And { track.data.respond_to? :annotation }
      And { track.data.respond_to? :title }
      And { track.data.respond_to? :trackNum }

      Then { track.location == location }
      And { track.album == "Album" }
      And { track.creator == "Artist" }
      And { track.annotation == "Comment" }
      And { track.title == "Title" }
      And { track.trackNum == 7 }
    end


    context "render" do
      When(:xml) { track.to_xml }
      Then { cmd(xml.chomp) == cmd( xml_comparator.chomp ) }
    end
  end
end

describe "Playlist" do
  context "Most simple case", :time_sensitive do
    Given(:options) {
      {
        "--title"       =>  nil,
        "--creator"     =>  nil,
        "--date"        =>  nil,
        "--annotation"  =>  nil,
        "--no-location" =>  false,
        "--no-title"    =>  false,
        "--no-artist"   =>  false,
        "--no-album"    =>  false,
        "--no-tracknum" =>  false,
        "--max-tracks"  =>  nil,
        "PATHS"=>["spec/support/fixtures/albums/mp4/mp4.m4a"],
      }
    }
    Given(:playlist) { Spfy::Playlist.new( options ) }
    Given(:xml_comparator) {
      track = Albums.join("mp4/mp4.m4a").to_path
      Fixtures.join("mp4.m4a.playlist.xml").read
        .sub( /FIXTURE/, Addressable::URI.join( "file:///", Addressable::URI.escape( track )).to_s  )
        .sub( /USER/, ENV["USER"] )
    }
    When(:xml) { playlist.to_xml }
    Then { cmd(xml.chomp) == cmd(xml_comparator.chomp) }
#     Then { playlist.options == {} }
#     Then { playlist.paths == [] }
#     Then { playlist.creator == "ME" }
#     Then { playlist.date == "today" }
#     Then { playlist.annotation == "notes" }
  end

  context "A directory of files", :time_sensitive do
    Given(:options) {
      {
        "--title"       =>  nil,
        "--creator"     =>  nil,
        "--date"        =>  nil,
        "--annotation"  =>  nil,
        "--no-location" =>  false,
        "--no-title"    =>  false,
        "--no-artist"   =>  false,
        "--no-album"    =>  false,
        "--no-tracknum" =>  false,
        "--max-tracks"  =>  nil,
        "PATHS"=>["spec/support/fixtures/albums/mp3"],
      }
    }
    Given(:playlist) { Spfy::Playlist.new( options ) }
    Given(:xml_comparator) {
      Fixtures.join("mp3.playlist.xml").read
        .gsub( /ALBUMS/, Addressable::URI.join( "file:///", Addressable::URI.escape( Albums.to_path)).to_s )
        .sub( /USER/, ENV["USER"] )
    }
    When(:xml) { playlist.to_xml }
    Then { cmd(xml.chomp) == cmd(xml_comparator.chomp) }
  end

  context "A directory of directories of files", :time_sensitive do
    Given(:options) {
      {
        "--title"       =>  nil,
        "--creator"     =>  nil,
        "--date"        =>  nil,
        "--annotation"  =>  nil,
        "--no-location" =>  false,
        "--no-title"    =>  false,
        "--no-artist"   =>  false,
        "--no-album"    =>  false,
        "--no-tracknum" =>  false,
        "--max-tracks"  =>  nil,
        "PATHS"=>["spec/support/fixtures/albums"],
      }
    }
    Given(:playlist) { Spfy::Playlist.new( options ) }
    Given(:xml_comparator) {
      Fixtures.join("all-albums.playlist.xml").read
        .gsub( /ALBUMS/, Addressable::URI.join( "file:///", Addressable::URI.escape( Albums.to_path)).to_s )
        .sub( /USER/, ENV["USER"] )
    }
    When(:xml) { playlist.to_xml }
    Then { cmd(xml.chomp) == cmd(xml_comparator.chomp) }
  end

  context "Multiple locations", :time_sensitive do
    Given(:options) {
      {
        "--title"       =>  nil,
        "--creator"     =>  nil,
        "--date"        =>  nil,
        "--annotation"  =>  nil,
        "--no-location" =>  false,
        "--no-title"    =>  false,
        "--no-artist"   =>  false,
        "--no-album"    =>  false,
        "--no-tracknum" =>  false,
        "--max-tracks"  =>  nil,
        "PATHS"=>["spec/support/fixtures/albums/mp3", "spec/support/fixtures/albums/mp4"],
      }
    }
    Given(:playlist) { Spfy::Playlist.new( options ) }
    Given(:xml_comparator) {
      Fixtures.join("mp3-and-mp4.playlist.xml").read
        .gsub( /ALBUMS/, Addressable::URI.join( "file:///", Addressable::URI.escape( Albums.to_path)).to_s  )
        .sub( /USER/, ENV["USER"] )
    }
    When(:xml) { playlist.to_xml }
    Then { cmd(xml.chomp) == cmd(xml_comparator.chomp) }
  end

  context "Given a max number of tracks" do
    context "When the no. of tracks found is greater" do
      Given(:options) {
        {
          "--title"       =>  nil,
          "--creator"     =>  nil,
          "--date"        =>  nil,
          "--annotation"  =>  nil,
          "--no-location" =>  false,
          "--no-title"    =>  false,
          "--no-artist"   =>  false,
          "--no-album"    =>  false,
          "--no-tracknum" =>  false,
          "--max-tracks"  =>  10,
          "PATHS"=>["spec/support/fixtures/albums"],
        }
      }
      Given(:playlist) { Spfy::Playlist.new( options ) }
      When(:xml) { playlist.to_xml }
      Then {
        options["--max-tracks"].to_i ==
          cmd(xml.chomp).split("\n")
                      .select{|line|
                        line =~ /\<track\>/
                      }.size
      }
    end
    context "When the no. of tracks found is less", :time_sensitive do
      Given(:options) {
        {
          "--title"       =>  nil,
          "--creator"     =>  nil,
          "--date"        =>  nil,
          "--annotation"  =>  nil,
          "--no-location" =>  false,
          "--no-title"    =>  false,
          "--no-artist"   =>  false,
          "--no-album"    =>  false,
          "--no-tracknum" =>  false,
          "--max-tracks"  =>  10,
          "PATHS"=>["spec/support/fixtures/albums/mp3"],
        }
      }
      Given(:playlist) { Spfy::Playlist.new( options ) }
      Given(:xml_comparator) {
        Fixtures.join("mp3.playlist.xml").read
          .gsub( /ALBUMS/, Addressable::URI.join( "file:///", Addressable::URI.escape( Albums.to_path)).to_s )
          .sub( /USER/, ENV["USER"] )
      }
      When(:xml) { playlist.to_xml }
      Then { cmd(xml.chomp) == cmd(xml_comparator.chomp) }
      Then {
        options["--max-tracks"].to_i >
          cmd(xml.chomp).split("\n")
                      .select{|line|
                        line =~ /\<track\>/
                      }.size
      }
    end
  end

  context "Given paths with no media files" do
    Given(:options) {
      {
        "--title"       =>  nil,
        "--creator"     =>  nil,
        "--date"        =>  nil,
        "--annotation"  =>  nil,
        "--no-location" =>  false,
        "--no-title"    =>  false,
        "--no-artist"   =>  false,
        "--no-album"    =>  false,
        "--no-tracknum" =>  false,
        "--max-tracks"  =>  10,
        "PATHS"=>["spec/support/fixtures/albums/empty"],
      }
    }
    Given(:playlist) { Spfy::Playlist.new( options ) }
    Then { expect { playlist.to_xml }.to raise_error(Spfy::Error) }
  end
end