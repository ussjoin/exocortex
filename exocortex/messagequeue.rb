require 'singleton'

module ExoCortex
  class MessageQueue
    include Singleton
        
    def initialize(options = {})
      @messages = Queue.new
    end  

    def add_message(message)
      @messages.push(message)
    end
    
    def message
      if (@messages.empty?)
        nil
      else
        @messages.pop
      end
    end
    
  end
end