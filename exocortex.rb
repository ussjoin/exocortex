#!ruby

require 'rubygems'

require 'exocortex/configuration'
require 'exocortex/messagequeue'
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

Shoes.app :width=> 640, :height => 400 do
  
  #Initial layout setup
  stack do
    @editline = edit_line :width => 600
    @itemstack = stack
  end
  
  # Message Queue
  @queue = ExoCortex::MessageQueue.instance
  
  # Module Invocations
  @twitter = ExoCortex::Twitter.new
  @twitter.start_long_running_thread
  

  
  #Animation runner
  animate(1) do |frame|
    message = @queue.message
    if (!message.nil?)
      @itemstack.prepend do
        stack :margin => 1 do
          background black
          para message, :stroke => white
        end
      end
    end
  end
end
