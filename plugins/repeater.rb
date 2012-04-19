class Repeater
  include Cinch::Plugin

  $help_messages << "#{$settings['settings']['nick']}: ping everyone in the room"
  $help_messages << "all: <message>   ping everyone in the room"

  listen_to :channel

  def nicks(m)
    names = m.channel.users.keys.map(&:nick).reject{|n|[$settings['settings']['nick'],m.user.nick].include?(n)}
    names.join(' ') unless names.empty?
  end

  def listen(m)
    case m.message
    when /^all:/
      if n = nicks(m)
        m.reply "#{nicks(m)}: ^"
      else
        m.reply "You're the only one here, idiot"
      end
    when /^#{$settings['settings']['nick']}.*ping/
      if n = nicks(m)
        m.reply "#{nicks(m)}: ping"
      else
        m.reply "You're the only one here, idiot"
      end
    end
  end

end
