require 'exocortex/configuration'
require 'exocortex/messagequeue'
require 'exocortex/twitter'


require 'singleton'

module ExoCortex
  class View
    include Singleton
    
    attr_reader :queue, :twitter
    
    def initialize
      # Message Queue
      @queue = ExoCortex::MessageQueue.instance

      # Module Invocations
      @twitter = ExoCortex::Twitter.new
      @twitter.start_long_running_thread
    end
  
    def parse(command_string)
      pt = command_string.index(/\s/)
      if (!pt.nil?)
        @command = command_string[0...pt]
        @parameter_string = command_string[pt+1...command_string.length]
        @parameter_string.strip!
      else
        @command = command_string
        @parameter_string = nil
      end
      case @command
      when /^tweet/i
        @twitter.update(@parameter_string)
        @queue.add_message("Tweeted: \"#{@parameter_string}\"")
      when /^twitter/i
        @twitter.process_command(@parameter_string)
      else
        @queue.add_message("Unrecognized Command: \"#{command_string}\"")
      end
    end

    def ExoCortex::shutdown
      # May want to do cleanup here first!
      Configuration.instance.dump
      exit
    end
  
    def run
      Shoes.app :width=> 640, :height => 400 do
        #Initial layout setup
        stack do
          flow do
            @editline = edit_box :width => 580, :height => 20 do |e|
              if (e.text.index(/\n/))
                ExoCortex::View.instance.parse(e.text.chomp)
                e.text = nil
              end
            end
            @queuelength = flow :width => 50
          end
          @itemstack = stack
        end
        @editline.focus

        #Animation runner
        animate(4) do |frame|
          message = ExoCortex::View.instance.queue.message
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
                tagline message.to_s, :stroke => str
              end
            end
          end
          @queuelength.clear {para " #{ExoCortex::View.instance.queue.length}"}
        end
      end
    end
  end
end