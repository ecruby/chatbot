require 'rubygems'
require 'cinch'



@irc = Cinch.setup :verbose => true do
  server "irc.freenode.org"
end

@help_messages = []

require 'modules/grammar_game'



@irc.plugin "help" do |m|
  @irc.privmsg m.nick, "Help"
  @help_messages.each{|message| @irc.privmsg(m.nick, message)}
end

@irc.run
