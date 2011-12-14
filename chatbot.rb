require 'rubygems'
require 'cinch'
require 'yaml'
begin
  settings = YAML.load(File.read("bot.yml"))
rescue
  puts "create bot.yml and populate it with values. See the readme file!"
end

$help_messages = ["This is a test"]

require './plugins/karma'
require './plugins/link_catcher'
require './plugins/blackjack'

@irc  = Cinch::Bot.new do
  
  configure do |c|
    c.server = "irc.freenode.org"
    c.nick = settings["settings"]["nick"]
    c.channels = [settings["settings"]["channel"]]
    # c.plugins.plugins = [Karma, LinkCatcher, Blackjack]
    c.plugins.plugins = [Blackjack]
  end

  on :message, /^!help/ do |m|
    $help_messages.each{|message| m.user.send message }
  end

end

@irc.start
