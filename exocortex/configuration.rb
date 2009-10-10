require 'yaml'

module ExoCortex
  class Configuration
    def Configuration::blank_config
      {}
    end
    
    def initialize(options = {})
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
    
  end
end