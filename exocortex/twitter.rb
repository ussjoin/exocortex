require 'twitter_oauth'

module ExoCortex
  class Twitter
    def Twitter::blank_config
      {
        "twitter" => {
          "consumer_key" => nil,
          "consumer_secret" => nil,
          "access_token" => nil,
          "access_token_secret" => nil,
        }
      }
    end
    
    def initialize(options = {})
      conf = options["configuration"].hash["twitter"]
      @consumer_key = conf["consumer_key"]
      @consumer_secret = conf["consumer_secret"]
      @token = conf["access_token"]
      @secret = conf["access_token_secret"]
      if (@consumer_key.nil? || @consumer_secret.nil?)
        puts "Please enter the Twitter API credentials in the config file."
        conf.merge!(Twitter::blank_config)
        shutdown
      end

      if (@token.length > 0)
        client=TwitterOAuth::Client.new( 
          :consumer_key => @consumer_key,
          :consumer_secret => @consumer_secret,
          :token => @token,
          :secret => @secret)
      else
        client=TwitterOAuth::Client.new( 
          :consumer_key => @consumer_key,
          :consumer_secret => @consumer_secret)
      end


      while (!client.authorized?)
        puts "No Twitter token found; please go to this URL and authorize me."
        request_token = client.request_token
        puts request_token.authorize_url
        puts "Enter the PIN it gave you here:"
        verifier = gets.chomp
        access_token = client.authorize(
          request_token.token,
          request_token.secret,
          :oauth_verifier => verifier)
        puts "Twitter credentials obtained."
        conf["twitter_access_token"] = access_token.token
        conf["twitter_access_token_secret"] = access_token.secret
        write_out_conf(conf)
      end

      puts "Twitter: ready to go."
    end  
  end
end