require 'singleton'

module ExoCortex
  class MessageQueue
    include Singleton
        
    def initialize(options = {})
      @alerts = Queue.new
      @messages = Queue.new
    end  
        
    def add_alert(alert)
      @alerts.push(alert)
    end
    
    def alert
      if (@alerts.empty?)
        nil
      else
        @alerts.pop
      end
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