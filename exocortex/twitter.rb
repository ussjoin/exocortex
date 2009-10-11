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
    
    def initialize(options = {})
      conf = Configuration.instance.hash
      if (conf["twitter"].nil?)
        puts "Please enter the Twitter API credentials in the config file."
        Configuration.instance.update_namespace("twitter", Twitter::blank_config)
        exit
      end
      @config = conf["twitter"]
      @consumer_key = @config["consumer_key"]
      @consumer_secret = @config["consumer_secret"]
      @token = @config["access_token"]
      @secret = @config["access_token_secret"]
      if (@consumer_key.nil? || @consumer_secret.nil?)
        puts "Please enter the Twitter API credentials in the config file."
        conf.merge!(Twitter::blank_config)
        exit
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
        puts "No Twitter token found; please go to this URL and authorize me."
        request_token = @client.request_token
        puts request_token.authorize_url
        puts "Enter the PIN it gave you here:"
        verifier = gets.chomp
        access_token = @client.authorize(
          request_token.token,
          request_token.secret,
          :oauth_verifier => verifier)
        puts "Twitter credentials obtained."
        @config["access_token"] = access_token.token
        @config["access_token_secret"] = access_token.secret
        Configuration.instance.update_namespace("twitter", @config)
      end
    end
    
    def method_missing method,*args
      @client.send method,*args
    end
    
    
  end
end