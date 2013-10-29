require 'cinch'
require 'open-uri'
require 'json'

load "env.rb" if File.exist?("env.rb")

def hash_to_params(hash)
  hash.map { |k,v| "#{k.to_s}=#{v.to_s}" }.join("&")
end

bot = Cinch::Bot.new do
  configure do |c|
    c.server = ENV['SERVER']
    c.channels = ENV['CHANNELS'].split(",")
    c.nick = ENV['NICK']
  end

  on :message, "!hello" do |m|
    m.reply "hello, #{m.user.nick}"
  end
  
  on :message, "!github" do |m|
    m.reply "https://github.com/kennygao/renaissance"
  end
  
  on :message, /^!dota (.+)/ do |m, account_id|
    params_hash = {
      account_id: account_id,
      matches_requested: "1",
      key: ENV['STEAM_WEB_API_KEY']
    }
    
    uri = "https://api.steampowered.com/IDOTA2Match_570/GetMatchHistory/V001/?#{hash_to_params(params_hash)}"
    debug "[REQUEST] #{uri}"
    
    response = JSON.parse(open(uri).read)
    match_id = response["result"]["matches"].first["match_id"]

    m.reply "#{m.user.nick}: http://dotabuff.com/matches/#{match_id}"
  end
end

bot.start
