require 'yaml'
require 'singleton'

module ExoCortex
  class Configuration
    include Singleton
    
    def initialize(options = {})
      reload_configuration
    end
    
    def reload_configuration
      begin
      @conf = YAML.load_file('config.yaml')
      rescue Exception => e
        @conf = {}
        File.open( 'config.yaml', 'w' ) do |out|
          YAML.dump(@conf, out)
        end
      end
    end
    
    def hash
      @conf
    end
    
    def dump
      File.open( 'config.yaml', 'w' ) do |out|
        YAML.dump(@conf, out)
      end
    end
    
    def update_value(category, key, value)
      @conf[category][key] = value
      self.dump
    end
    
    def update_namespace(category, hash)
      @conf[category] = hash
      self.dump
    end
    
  end
end