#!ruby

require 'rubygems'
require 'readline'
require 'ncurses'

require 'exocortex/configuration'
require 'exocortex/twitter'

trap('INT') { shutdown }

def readline_with_hist_management
  line = Readline.readline('> ', true)
  return nil if line.nil?
  if line =~ /^\s*$/ or Readline::HISTORY.to_a[-2] == line
    Readline::HISTORY.pop
  end
  line.strip
end

@config = nil

def shutdown
  # May want to do cleanup here first!
  @config.dump
  exit
end

@config = ExoCortex::Configuration.new

@twitter = ExoCortex::Twitter.new({"configuration" => @config})






