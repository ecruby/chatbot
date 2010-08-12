require 'rubygems'
require 'cinch'
@grammar_points = {}
irc = Cinch.setup :verbose => true do
  server "irc.freenode.org"
end

irc.plugin "help" do |m|
  m.reply "!points          shows your score"
  m.reply "!scoreboard      shows all scores"
  m.reply "!grammar <nick>  Grammar violation"
  m.reply "!element <nick>  Out of element"
  m.reply "!props <nick>    Give props"
end


irc.plugin "props :nick"  do |m|
  nick = m.args[:nick]
  if nick == m.nick
    reduce_points(m.nick, 50)
    m.reply "#{m.nick} loses 50 for patting himself on the back." 
  else
    add_points(nick, 10)
    m.reply "#{nick} is apparently awesome. +10 points."
  end
end

irc.plugin "element :nick" do |m|
  nick = m.args[:nick]
  reduce_points(nick, 20)
  m.reply "#{nick} is out of his or her element. -20 points."
end

irc.plugin "grammar :nick"  do |m|
  nick = m.args[:nick]
  reduce_points(nick, 10)
  m.reply "#{nick} fails at grammar. -10 points."
end

irc.plugin "points" do |m|
   m.reply points(m.nick)
end

irc.plugin "scoreboard" do |m|
  @grammar_points.each do |key, val|
    m.reply points(key)
  end
end


irc.run


# ****************************
def reduce_points(nick, number)
  default(nick)
  @grammar_points[nick] -= number
end

def add_points(nick, number)
  default(nick)
  @grammar_points[nick] += number
end

def default(nick)
  @grammar_points[nick] ||= 0
end

def points(nick)
  default(nick)
  "#{nick} has #{@grammar_points[nick]}"
end

