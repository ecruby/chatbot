@grammar_points = {}

@help_messages << "!props <nick>    Give props"
@irc.plugin "props :nick"  do |m|
  nick = m.args[:nick]
  if nick == m.nick
    reduce_points(m.nick, 50)
    m.reply "#{m.nick} loses 50 for patting himself on the back." 
  else
    add_points(nick, 10)
    m.reply "#{nick} is apparently awesome. +10 points."
  end
end

@help_messages << "!element <nick>  Out of element"
@irc.plugin "element :nick" do |m|
  nick = m.args[:nick]
  reduce_points(nick, 20)
  m.reply "#{nick} is out of his or her element. -20 points."
end

@help_messages << "!grammar <nick>  Grammar violation"
@irc.plugin "grammar :nick"  do |m|
  nick = m.args[:nick]
  reduce_points(nick, 10)
  m.reply "#{nick} fails at grammar. -10 points."
end

@help_messages << "!points          shows your score"
@irc.plugin "points" do |m|
  m.reply points(m.nick)
end

@help_messages << "!scoreboard      shows all scores"
@irc.plugin "scoreboard" do |m|
  @grammar_points.each do |key, val|
    m.reply points(key)
  end
end




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
