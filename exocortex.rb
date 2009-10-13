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

  # Message Queue
  @queue = ExoCortex::MessageQueue.instance

  # Module Invocations
  @twitter = ExoCortex::Twitter.new
  @twitter.start_long_running_thread

  
  #Initial layout setup
  stack do
    @editline = edit_line :width => 600
    @itemstack = stack
  end
  
  #Animation runner
  animate(1) do |frame|
    message = @queue.message
    if (!message.nil?)
      @itemstack.prepend do
        stack :margin => 1 do
          back = black
          if message.respond_to?("block_background")
            back =  message.block_background
          end
          
          str = white
          if (message.respond_to?("block_stroke_color"))
            str = message.block_stroke_color
          end
          
          background back
          para message.to_s, :stroke => str
        end
      end
    end
  end
end
