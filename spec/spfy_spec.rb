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
  context "Most simple case" do
    Given(:path) { Albums.join("mp4/mp4.m4a") }
    Given(:track) { Spfy::Track.new path }
    # Mung the path in the file so it works on any machine
    Given(:xml_comparator) { Fixtures.join("mp4.m4a.xml").read.sub /FIXTURE/, Albums.join("mp4/mp4.m4a").to_path }
    When(:xml) { track.to_xml }
    Then { cmd(xml.chomp) == cmd( xml_comparator.chomp ) }
  end
end

describe "Playlist" do
  context "Most simple case", :time_sensitive do
    Given(:options) {
      {
        "--help"        =>  false,
        "--output"      =>  nil,
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
        "--version"     =>  false
      }
    }
    Given(:playlist) { Spfy::Playlist.new( options ) }
    Given(:xml_comparator) {
      Fixtures.join("mp4.m4a.playlist.xml").read
        .sub( /FIXTURE/, Albums.join("mp4/mp4.m4a").to_path )
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
        "--help"        =>  false,
        "--output"      =>  nil,
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
        "--version"     =>  false
      }
    }
    Given(:playlist) { Spfy::Playlist.new( options ) }
    Given(:xml_comparator) {
      Fixtures.join("mp3.playlist.xml").read
        .gsub( /ALBUMS/, Albums.to_path )
        .sub( /USER/, ENV["USER"] )
    }
    When(:xml) { playlist.to_xml }
    Then { cmd(xml.chomp) == cmd(xml_comparator.chomp) }
  end

  context "A directory of directories of files", :time_sensitive do
    Given(:options) {
      {
        "--help"        =>  false,
        "--output"      =>  nil,
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
        "--version"     =>  false
      }
    }
    Given(:playlist) { Spfy::Playlist.new( options ) }
    Given(:xml_comparator) {
      Fixtures.join("all-albums.playlist.xml").read
        .gsub( /ALBUMS/, Albums.to_path )
        .sub( /USER/, ENV["USER"] )
    }
    When(:xml) { playlist.to_xml }
    Then { cmd(xml.chomp) == cmd(xml_comparator.chomp) }
  end

  context "Multiple locations", :time_sensitive do
    Given(:options) {
      {
        "--help"        =>  false,
        "--output"      =>  nil,
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
        "--version"     =>  false
      }
    }
    Given(:playlist) { Spfy::Playlist.new( options ) }
    Given(:xml_comparator) {
      Fixtures.join("mp3-and-mp4.playlist.xml").read
        .gsub( /ALBUMS/, Albums.to_path )
        .sub( /USER/, ENV["USER"] )
    }
    When(:xml) { playlist.to_xml }
    Then { cmd(xml.chomp) == cmd(xml_comparator.chomp) }
  end
end