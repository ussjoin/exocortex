Shoes.setup do
  gem 'oauth'
  gem 'json'
  gem 'mime-types'
  
  source 'http://gems.github.com'
  gem 'moomerman-twitter_oauth'
end

require 'twitter_oauth'

module ExoCortex
  class Twitter
    def Twitter::blank_config
      {
        "consumer_key" => nil,
        "consumer_secret" => nil,
        "access_token" => nil,
        "access_token_secret" => nil,
      }
    end
    
    def get_secrets
      conf = Configuration.instance.hash
      flag = true
      if (conf["twitter"].nil?)
        flag = false
      else
        @config = conf["twitter"]
        @consumer_key = @config["consumer_key"]
        @consumer_secret = @config["consumer_secret"]
        @token = @config["access_token"]
        @secret = @config["access_token_secret"]
        if (@consumer_key.nil? || @consumer_secret.nil?)
          flag = false
        end
      end
      flag
    end
    
    def initialize   
      while (!get_secrets)
        Configuration.instance.update_namespace("twitter", Twitter::blank_config)
        Configuration.instance.dump
        alert "Please enter the Twitter API credentials in the config file. Hit OK when done."
        Configuration.instance.reload_configuration
      end

      if (!@token.nil?)
        @client=TwitterOAuth::Client.new( 
          :consumer_key => @consumer_key,
          :consumer_secret => @consumer_secret,
          :token => @token,
          :secret => @secret)
      else
        @client=TwitterOAuth::Client.new( 
          :consumer_key => @consumer_key,
          :consumer_secret => @consumer_secret)
      end


      while (!@client.authorized?)
        request_token = @client.request_token
        verifier = ask "No Twitter token found; please go to the URL, authorize me, and give me the PIN:\n"+request_token.authorize_url        
        access_token = @client.authorize(
          request_token.token,
          request_token.secret,
          :oauth_verifier => verifier)
        @config["access_token"] = access_token.token
        @config["access_token_secret"] = access_token.secret
        Configuration.instance.update_namespace("twitter", @config)
        Configuration.instance.dump
      end
    end
    
    def method_missing method,*args
      @client.send method,*args
    end
    
    def start_long_running_thread
      #Todo: Make this actually periodically check for more after the first run
      queue = ExoCortex::MessageQueue.instance
      Thread.new do
        self.home_timeline.reverse.each do |item|
          queue.add_message(Tweet.new(item))
        end
      end
    end
  end
  
  class Tweet
    # This is what Twitter will throw into the message queue
    @item_hash
    def initialize(item_hash)
      info("setup")
      @item_hash = item_hash
    end
    
    def block_background
      Shoes.rgb(0,0,0)
    end
    
    def block_stroke_color
      Shoes.rgb(255,255,255)
    end
    
    def to_s
      "#{@item_hash['user']['screen_name']}: #{@item_hash['text']}"
    end
    
  end
end