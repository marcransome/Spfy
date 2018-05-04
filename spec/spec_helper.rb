require 'simplecov'
require "rspec/its"
require "rspec-given"
require 'timecop'

SimpleCov.start do
  add_filter "/spec/"
  add_filter "/coverage/"
  add_filter "/vendor.noindex/"
end

require 'pathname'
Fixtures = Pathname(__dir__).join("support/fixtures")

if ENV["DEBUG"]
  require 'pry-byebug'
  require 'pry-state'
  binding.pry
end


RSpec.configure do |config|
  config.expect_with(:rspec) { |c| c.syntax = [:should,:expect] }

  config.before(:each, :time_sensitive => true) do
    Timecop.freeze Time.parse "2018-03-11T06:49:16+00:00"
  end

  config.after(:each, :time_sensitive => true) do
    Timecop.return
  end
end