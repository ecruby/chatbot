require 'rubygems'
require 'cinch'
require 'cinch/plugins/identify'
require 'yaml'

begin
  $settings = YAML.load(File.read("bot.yml"))
rescue
  puts "create bot.yml and populate it with values. See the readme file!"
end

# This method is taken from rails core
# (didn't want to load the entire lib for one method)
# http://api.rubyonrails.org/classes/ActiveSupport/Inflector.html#method-i-constantize
def constantize(camel_cased_word)
  names = camel_cased_word.split('::')
  names.shift if names.empty? || names.first.empty?

  constant = Object
  names.each do |name|
    constant = constant.const_defined?(name) ? constant.const_get(name) : constant.const_missing(name)
  end
  constant
end

$help_messages = []

$settings["settings"]["plugins"].each do |plugin|
  require "./plugins/#{plugin}"
end

@irc  = Cinch::Bot.new do
  
  configure do |c|
    c.server = "irc.freenode.org"
    c.nick = $settings["settings"]["nick"]
    c.channels = [$settings["settings"]["channel"]]
    c.plugins.plugins = $settings["settings"]["cinch_plugins"] +
                        $settings["settings"]["plugins"].map {|plugin| constantize(plugin.split("_").map {|word| word.capitalize}.join(""))}
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
