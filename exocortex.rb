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

def shutdown
  # May want to do cleanup here first!
  ExoCortex::Configuration.instance.dump
  exit
end

at_exit {shutdown}

@twitter = ExoCortex::Twitter.new




