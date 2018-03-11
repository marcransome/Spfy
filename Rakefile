require 'pathname'

desc "Install the spec fixtures"
task :fixtures do
  gem_home = Pathname(ENV["GEM_HOME"])
  files = gem_home.join("gems").glob("taglib-ruby-*/test/data/*").reject{|x| x.extname.to_s == ".cpp" }
  # mk dir tree
  spec_dir = Pathname(__dir__).join("spec/support/fixtures/albums")
  spec_dir.mkpath
  %w{flac mp3 mp4 oga wav}.each do |ext|
    album = spec_dir.join(ext)
    album.mkpath
    # find taglib and copy files
    # And yes, this is a horrible hack
    if ext == "mp4"
      exts = ["m4a","aiff"]
    else
      exts = [ext]
    end
    exts.each do |ext|
      FileUtils.cp files.select{|x| x.extname.to_s == ".#{ext}" }, album
    end
  end
  puts "Audio files copied from taglib to spec/support/fixtures/albums"
end