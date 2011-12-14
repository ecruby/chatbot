class Blackjack
  include Cinch::Plugin
  
  SUITS = %w{spades hearts clubs diamonds}
  RANK_TO_NAME = %w{ace two three four five six seven eight nine ten jack queen king}

  def initialize(*args)
    super
    @playing = false
    @played_cards = []
    @players = []
    @hands = {}
    @standing = 0
    @turn = 0
  end

  $help_messages << "!blackjack       Start a hand"
  match /blackjack/, method: :blackjack 

  $help_messages << "!dealmein        Be dealt into a hand"
  match /dealmein/, method: :dealmein

  match /hit/, method: :hit
  match /stand/, method: :stand

  def blackjack(m)
    @playing = true
    @played_cards = []
    @players = [m.user.nick]
    @hands = {}
    @standing = []
    @turn = 0
    @hands[:dealer] = []

    m.reply "I'm about to deal a hand of blackjack. Hit '!dealmein' if you want in."
    sleep 20
    m.reply "Alrighty, #{@players.join(', ')} #{@players[1] ? "are" : "is"} playing."
    sleep 5
    deal(m)
    c = card
    @hands[:dealer] << c
    m.reply "dealer gets #{c[0]}"
    deal(m)
    c = card
    @hands[:dealer] << c
    m.reply "dealer is dealt a card face down"
    player = @players[@turn]
    m.reply "#{player} has #{score(player)}. !hit or !stand"
  end

  def hit(m)
    unless m.user.nick == @players[@turn]
      m.reply "It's not your turn."
      return
    end
    player = m.user.nick
    c = card
    (@hands[player]||=[]) << c
    if score(player) > 21
      m.reply "#{player} gets #{c[0]} and busts."
      @players.delete(player)
    else
      m.reply "#{player} gets #{c[0]}, now at #{score(player)}"
    end
    hand_meta(m)
  end

  def stand(m)
    unless m.user.nick == @players[@turn]
      m.reply "It's not your turn."
      return
    end
    player = m.user.nick
    m.reply "#{player} stands with #{score(player)}"
    @standing << player
    hand_meta(m)
  end

  def hand_meta(m)
    check_for_forfeiture(m)
    if @standing.size == @players.size && !@players.empty?
      endgame(m)
    else
      @turn = (@turn+1) % @players.size
      @turn = (@turn+1) % @players.size until !@standing.include?(@players[@turn])
      player = @players[@turn]
      m.reply "#{player} has #{score(player)}. !hit or !stand"
    end
  end

  def endgame(m)
    for player in @players
      m.reply "#{player} has #{score(player)}"
    end
    m.reply "dealer reveals a #{@hands[:dealer].last[0]}"
    m.reply "dealer has #{score(:dealer)}"
    while score(:dealer) < 17
      c = card
      @hands[:dealer] << c
      if score(:dealer) <= 21
        m.reply "dealer gets #{c[0]}"
      else
        m.reply "dealer get #{c[0]} and busts."
      end
    end
    if score(:dealer) > 21
      m.reply "#{@players.join(', ')} #{@players[1] ? 'have' : 'has'} won!"
    else
      m.reply "dealer stands with #{score(:dealer)}"
      winners = @players.select do |player|
        score(player) > score(:dealer)
      end
      if winners.empty?
        m.reply "dealer wins!"
      else 
        m.reply "#{winners.join(', ')} #{winners[1] ? 'have' : 'has'} won!"
      end    
    end
  end

  def score(player)
    hand = @hands[player]
    aces = hand.inject(0){|s,e| e[1]==0 ? s+1 : s}
    sum = hand.inject(0){|s,e| s+(e[1] > 9 ? 10 : (e[1]==0 ? 11 : e[1]+1))}
  end

  def dealmein(m)
    @players << m.user.nick unless @players.include?(m.user.nick)
  end

  def deal(m)
    check_for_forfeiture(m)
    for player in @players
      c = card
      (@hands[player]||=[]) << c
      m.reply "#{player} gets #{c[0]}"
    end
  end

  def check_for_forfeiture(m)
    @players.each do |player|
      unless m.channel.users.collect{|u|u.first.nick}.include? player
        m.reply "#{player} forfeits."
        @players.delete(player)
      end
    end
    if @players.empty?
      m.reply "Alrighty, so much for blackjack. I'm gonna shoot some craps."
    end
  end

  def card
    rank = rand(13)
    suit = rand(4)
    if @played_cards.include?([rank,suit])
      card
    else
      @played_cards << [rank,suit]
      ["#{RANK_TO_NAME[rank]} of #{SUITS[suit]}",rank]
    end
  end

end
