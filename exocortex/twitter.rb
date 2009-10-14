Shoes.setup do
  # Prerequisites for moomerman-twitter_oauth
  gem 'oauth'
  gem 'json'
  gem 'mime-types'
  
  source 'http://gems.github.com'
  gem 'moomerman-twitter_oauth'
end

require 'twitter_oauth'

# Monkeypatch: Making TwitterOAuth not return search results only in an OpenStruct, which is obnoxious IMHO.
module TwitterOAuth
  class Client
    def search(q, options={})
      options[:page] ||= 1
      options[:per_page] ||= 20
      response = open("http://search.twitter.com/search.json?q=#{URI.escape(q)}&page=#{options[:page]}&rpp=#{options[:per_page]}&since_id=#{options[:since_id]}")
      search_result = JSON.parse(response.read)
      search_result["results"]
    end
  end
end


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
    
    def handled_commands
      ["tweet"]
    end
    
    def initialize
      @since_id = {"home" => 0, "mentions" => 0}
      
      while (!get_secrets)
        Configuration.instance.update_namespace("twitter", Twitter::blank_config)
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
        verifier = ask "No Twitter token found; please go to this URL, authorize me, and give me the PIN: "+request_token.authorize_url
        begin
          access_token = @client.authorize(
            request_token.token,
            request_token.secret,
            :oauth_verifier => verifier)
          @config["access_token"] = access_token.token
          @config["access_token_secret"] = access_token.secret
          Configuration.instance.update_namespace("twitter", @config)
        rescue Exception => e
          # Do nothing; just let it loop.
        end
      end
    end
    
    def method_missing method,*args
      @client.send method,*args
    end
    
    def start_long_running_thread
      Thread.new do
        while (true)
          enqueue_new_messages
          sleep(60) # I have a Twitter Dev Account (20K limit/hr), so I can do this. Todo: Should be tuneable.
        end
      end
    end
    
    def enqueue_new_messages
      @since_id.keys.each do |k|
        enqueue_messages(k)
      end
    end
    
    private
    
    def enqueue_messages(kind)
      queue = ExoCortex::MessageQueue.instance
      
      case kind
      when "home"
        if (@since_id[kind] > 0)
          messages = self.home_timeline({"since_id" => @since_id[kind]})
        else
          messages = self.home_timeline
        end
      when "mentions"
        if (@since_id[kind] > 0)
          messages = self.mentions({"since_id" => @since_id[kind]})
        else
          messages = self.mentions
        end
      else
        if (@since_id[kind] > 0)
          messages = self.search(kind, {:since_id => @since_id[kind]})
        else
          messages = self.search(kind)
        end
      end

      messages.reverse.each do |item|
        if (item["id"].to_i > @since_id[kind])
          @since_id[kind] = item["id"].to_i
        end
        queue.add_message(Tweet.new(kind, item))
      end
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
  end
  
  class Tweet
    # This is what Twitter will throw into the message queue
    def initialize(kind, item_hash)
      @item_hash = item_hash
      case kind
      when "home"
        @stroke_color = Shoes.rgb(255, 255, 255)
        @username = @item_hash['user']['screen_name']
      when "mentions"
        @stroke_color = Shoes.rgb(128, 128, 255)
        @username = @item_hash['user']['screen_name']
      else
        @stroke_color = Shoes.rgb(128, 255, 128)
        #Search API returns this differently, annoyingly
        @username = @item_hash['from_user']
      end
    end
    
    def block_background
      Shoes.rgb(0,0,0)
    end
    
    def block_stroke_color
      @stroke_color
    end
    
    def to_s
      "#{@username}: #{@item_hash['text']}"
    end
    
  end
end