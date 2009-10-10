#!ruby

require 'rubygems'
require 'readline'
require 'ncurses'
require 'yaml'
require 'twitter_oauth'

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
  exit
end

def tweet(message)
  puts "You wanted to tweet #{message}"
end

def write_out_conf(conf)
  puts "Writing configuration file now."
  File.open( 'config.yaml', 'w' ) do |out|
    YAML.dump(conf, out)
  end
end

begin
conf = YAML.load_file('config.yaml')
rescue Exception => e
  conf = nil
end

if (!conf)
  conf = {
    "twitter_consumer_key" => "",
    "twitter_consumer_secret" => "",
    "twitter_access_token" => "",
    "twitter_access_token_secret" => "",
    }
  write_out_conf(conf)
  shutdown
end

if (conf["twitter_consumer_key"].length == 0 ||
    conf["twitter_consumer_secret"].length == 0)
  puts "Please enter the Twitter API credentials in the config file."
  shutdown
end



request_token = nil
access_token = nil

if (conf["twitter_access_token"].strip.length > 0)
  client=TwitterOAuth::Client.new( 
    :consumer_key => conf["twitter_consumer_key"],
    :consumer_secret => conf["twitter_consumer_secret"],
    :token => conf["twitter_access_token"],
    :secret => conf["twitter_access_token_secret"])
else
  client=TwitterOAuth::Client.new( 
    :consumer_key => conf["twitter_consumer_key"],
    :consumer_secret => conf["twitter_consumer_secret"])
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

puts "Ready to go."


