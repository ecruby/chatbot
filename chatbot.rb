require 'rubygems'
require 'cinch'
require 'cinch/plugins/identify'
require 'yaml'

begin
  $settings = YAML.load(File.read("bot.yml"))
rescue
  puts "create bot.yml and populate it with values. See the readme file!"
end

$help_messages = []

require './plugins/karma'
require './plugins/link_catcher'
require './plugins/repeater'

@irc  = Cinch::Bot.new do
  
  configure do |c|
    c.server = "irc.freenode.org"
    c.nick = $settings["settings"]["nick"]
    c.channels = [$settings["settings"]["channel"]]
    c.plugins.plugins = [Karma, LinkCatcher, Repeater, Cinch::Plugins::Identify]
    c.plugins.options[Cinch::Plugins::Identify] = {
      :username => $settings['settings']['nick'],
      :password => $settings['settings']['nickserv_pass'],
      :type     => :nickserv
    }
  end

  on :message, /^!help/ do |m|
    $help_messages.each{|message| m.user.send message }
  end

end

@irc.start
