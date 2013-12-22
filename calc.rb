# coding=utf-8
# Blackjack game
# Author:Desmond

require 'pry'

# For general and erro output
module Output
  def say(str)
    "=> #{str}"
  end

  def error_prompt(str)
    "** Your input is incorrect. #{str}"
  end
end

# Super class for player and dealer
class Gamer
  include Output

  attr_accessor :cards, :points, :name

  def retrieve_card(card)
    cards << card
    cal_point

    if card.face == 'up'
      puts say("#{name} draws an #{card.suit} #{card.value}.")
    else
      puts say("#{name} draws a face down card.")
    end
  end

  def show_cards
    puts say("#{name} got")

    cards.each do |card|
      if card.face == 'down'
        puts say('Face down card')
      else
        puts say("#{card.suit} #{card.value}")
      end
    end
  end

  def show_points
    puts say("#{name}'s total point could be:")
    puts say("#{points.to_s}")
  end

  def cal_point
    point = 0
    self.points = []

    cards.each do |card|
      if %w(J K Q).include?(card.value)
        point += 10
      elsif card.value == 'A'
        point += 11
      else
        point += card.value.to_i
      end
    end

    points << point if point <= 21

    cards.select { |ele| ele.value == 'A' }.count.times do
      point -= 10
      points << point if point <= 21
    end
  end

  def is_busted?
    if points.empty?
      true
    else
      false
    end
  end
end

# Player Object
class Player < Gamer
  attr_accessor :money, :chips, :bet_chips, :insurance, :is_complete, :split_times, :parent

  # Limitation for split times
  SPLIT_MAX = 3

  def initialize(name, money)
    @cards = []
    @points = []
    @name = name
    @money = money
    @chips = 0
    @bet_chips = 0
    @insurance = false
    @is_complete = false
    @split_times = 0
    @parent = self
  end

  # Show chips and money
  def show_balance(minimum_bet)
    puts say("Hi, #{name}.")
    puts say("Your current chips are #{chips}.")
    puts say("Your current money is #{money}.")
    puts say("The minimum of the bet is #{minimum_bet}.")
  end

  def get_cash
    if chips == 0
      puts say('You do not have any chips!')
    else
      loop do
        puts say('Input cash you would like to exchange:')
        cash = gets.chomp
        if cash.to_i.to_s != cash
          puts error_prompt('Must be digits!')
        elsif cash.to_i < 0
          puts error_prompt('Not less than 0!')
        elsif cash.to_i > chips
          puts error_prompt('Your chips are not enough!')
        else
          self.money += cash.to_i
          self.chips -= cash.to_i
          break
        end
      end
    end
  end

  def get_chips
    if self.money == 0
      puts say('You do not have any money!')
    else
      loop do
        puts say('Input chips you would like to buy:')
        chips = gets.chomp
        if chips.to_i.to_s != chips
          puts error_prompt('Must be digits!')
        elsif chips.to_i < 0
          puts error_prompt('Not less than 0!')
        elsif chips.to_i > self.money
          puts error_prompt('Your money is not enough!')
        else
          self.money -= chips.to_i
          self.chips += chips.to_i
          break
        end
      end
    end
  end

  # Check whether player has enough chips to play
  # if not, player out of game
  def broke(list, minimum_bet)
    if self.chips < minimum_bet
      puts say('Your chips is not enough, you are out of the game.')
      puts say('Have a good one!')
      list << self
    else
      list
    end
  end

  def bet(minimum_bet)
    loop do
      puts say("Hi, #{name}")
      puts say("How many chips you want to bet(No less than #{minimum_bet}):")
      bet_chips = gets.chomp
      if bet_chips.to_i.to_s != bet_chips
        puts error_prompt('Must be digits!')
      elsif bet_chips.to_i < minimum_bet
        puts error_prompt("Not less than #{minimum_bet}!")
      elsif bet_chips.to_i > self.chips
        puts error_prompt('You do not have enough chips to bet!')
      elsif bet_chips.to_i % 10 != 0
        puts error_prompt('The minimum unit of your bet should be 10.(Such as 20,30...)')
      else
        self.bet_chips = bet_chips.to_i
        self.chips -= bet_chips.to_i
        break
      end
    end
    self.is_complete = false
  end

  def buy_insurance?(value)
    flag = false
    loop do
      puts say("Hi, #{name}")
      puts say("Dealer got an #{value}, he might hit Blackjack, would you like to buy insurance? 1) Yes 2) No")
      case gets.chomp
      when '1'
        puts say("#{name} buy an insurance.")
        self.bet_chips /= 2
        self.insurance = true
        flag = true
        break
      when '2' then break
      else          puts error_prompt('Input 1 or 2')
      end
    end
    flag
  end

  # Win situiation
  def won?(status)
    if status == 'blackjack'
      won_with_bj?
    elsif status == 'points'
      won_with_points
    elsif status == 'busted'
      won_with_busted
    end
  end

  # Player get Blackjack
  def won_with_bj?
    if points.include?(21)
      puts say("#{name} hit Blackjack! Get 2.5 times of bet. Win for #{name}")
      self.chips += self.bet_chips * 2.5
      self.is_complete = true
    end
  end

  # Player get larger point than dealer
  def won_with_points
    puts say("#{name}'s point is bigger than dealer! #{name} get extra one bet. Win for #{name}")
    if parent == self
      self.chips += 2 * self.bet_chips
    else
      parent.chips += 2 * self.bet_chips
    end
  end

  # Dealer busted
  def won_with_busted
    if parent == self
      self.chips += 2 * self.bet_chips
    else
      parent.chips += 2 * self.bet_chips
    end
  end

  # Lose situiation
  def lose?(status)
    if status == 'points'
      lose_with_points
    elsif status == 'busted'
      lose_with_busted
    elsif status == 'surrender'
      lose_with_surrender
    elsif status == 'insurance'
      lose_with_insurance
    end
  end

  # Player buy insurance without hitting Blackjack
  def lose_with_insurance
    puts say("#{name} do not hit Blackjack. #{name} lose bet. Lose for #{name}.")
    puts say("#{name} bought an insurance. Pay 2 times of insurance.")
    self.chips += 2 * self.bet_chips
  end

  # Player get smaller point than dealer
  def lose_with_points
    puts say("#{name}'s point is smaller than dealer! #{name} lose bet. Lose for #{name}")
  end

  # Player busted
  def lose_with_busted
    puts say("#{name} busted! #{name} lose bet. Lose for #{name}")
    self.is_complete = true
  end

  # Player surrender
  def lose_with_surrender
    puts say("#{name} surrender! #{name} lose half of bet. Lose for #{name}")
    self.chips += self.bet_chips / 2
    self.is_complete = true
  end

  # Push situiation
  def tie?(status)
    if status == 'points'
      tie_with_points
    elsif status == 'bj_insurance'
      tie_with_bj_insurance
    elsif status == 'bj'
      tie_with_bj
    end
  end

  # Both of player and gamer hit Blackjack
  def tie_with_bj
    puts say("#{name} hit Blackjack too! Push for #{name}.")
    self.chips += self.bet_chips
  end

  # Player buy insurance with hitting Blackjack
  def tie_with_bj_insurance
    puts say("#{name} hit Blackjack too! A push for #{name}.")
    puts say("#{name} bought an insurance. Pay 2 times of insurance.")
    self.chips += 3 * self.bet_chips
  end

  # Player gets same point as dealer gets
  def tie_with_points
    puts say("#{name}'s point is same as dealer! Push for #{name}.")
    if parent == self
      self.chips += self.bet_chips
    else
      parent.chips += self.bet_chips
    end
  end

  # Check whether split time hit limitation
  def split_max?
    if parent.split_times == SPLIT_MAX
      true
    else
      false
    end
  end

  # Split card, which parent is the original player
  def split_card(players)
    player = Player.new(parent.name + "SplitPlayer_#{parent.split_times + 1}", 0)
    player.bet_chips = parent.bet_chips
    parent.chips -= parent.bet_chips
    player.cards << cards.pop
    if parent == self
      player.parent = self
    else
      player.parent = parent
    end
    players.insert(players.index(self) + 1, player)
  end

  # Check whether chips is enough to split or double down
  def chips_enough?
    if parent.chips < parent.bet_chips
      false
    else
      true
    end
  end

  # Check whether player get two same value card to split
  def cards_same?
    if cards[0].value == cards[1].value
      true
    else
      false
    end
  end

  # Player exchange chips and cash
  def exchange(out_list, minimum_bet)
    show_balance(minimum_bet)
    loop do
      puts say('What would you like to do? 1) Get cash 2) Get chips 3) Balance 4) Continue ')
      puts say('Warning: If you do not have enough chips and choose to continue, you would')
      puts say('be automatically out of the game!')
      case gets.chomp
      when '1' then get_cash
      when '2' then get_chips
      when '3' then show_balance(minimum_bet)
      when '4' then break
      else
        puts error_prompt('Input 1 or 2 or 3')
      end
    end
    broke(out_list, minimum_bet)
  end
end

# Dealer object
class Dealer < Gamer
  def initialize
    @cards = []
    @points = []
    @name = 'Dealer'
  end

  # Check whether dealer can ask insurance to players
  def has_ten_plus?
    if %w(J K Q A 10).include?(cards[0].value)
      true
    else
      false
    end
  end

  # Check whether dealer hit Blackjack
  def dealer_bj?
    cards[1].face = 'up'
    puts say("The face down card is #{cards[1].suit} #{cards[1].value}")
    if points.include?(21)
      true
    else
      false
    end
  end

  # Check all of cards on dealer's hand include face down one
  def show_all_cards
    puts say("#{name} got")

    cards.each do |card|
      puts say("#{card.suit} #{card.value}")
    end
  end
end

# Card object
class Card
  attr_accessor :suit, :value, :face

  def initialize(suit, value)
    @suit = suit
    @value = value
    @face = 'up'
  end
end

# Deck object
class Deck
  include Output
  attr_accessor :cards, :deck_num

  @@values = %w(2 3 4 5 6 7 8 9 10 J Q K A)
  @@suits = %w(Spades Hearts Diamonds Clubs)

  def initialize(deck_num)
    @deck_num = deck_num
    @cards = shuffle_cards
  end

  def shuffle_cards
    cards = []

    deck_num.times do
      @@suits.each do |suit|
        @@values.each do |value|
          cards << Card.new(suit, value)
        end
      end
    end

    cards.shuffle!
  end

  # Regenerate and shuffle if cards less than half, precautian for counting cards
  def check_cards
    total_cards = deck_num * 52
    current_cards = cards.count
    if current_cards <= (total_cards / 2)
      puts say('Current cards are less than half of total cards.')
      puts say('Reshuffle the decks!')
      self.cards = shuffle_cards
    end
  end

  def deal_card
    cards.pop
  end
end

# Blackjack Game
class BlackJack
  include Output

  attr_accessor :players, :dealer, :deck, :minimum_bet

  def initialize
    @players = []
  end

  def run
    system 'clear' unless system 'cls'
    config
    start_game
  end

  def config
    puts say('Welcome to BlackJack Game!')
    puts say('Config and initialize the game:')

    set_deck
    set_minimum_bet
    set_gamers

    puts say('Configuration set!')
  end

  def set_deck
    loop do
      puts say('How many decks play in game(Range from 1-6):')
      deck_num = gets.chomp
      if %w(1 2 3 4 5 6).include?(deck_num)
        self.deck = Deck.new(deck_num.to_i)
        break
      else
        puts error_prompt('Range should from 1-6!')
      end
    end
  end

  def set_minimum_bet
    loop do
      puts say('What is the minimum bet in game(Not less than 10):')
      minimum = gets.chomp

      if minimum.to_i.to_s != minimum
        puts error_prompt('Must be digits!')
      elsif minimum.to_i < 10
        puts error_prompt('Not less than 10!')
      else
        self.minimum_bet = minimum.to_i
        break
      end
    end
  end

  def set_gamers
    loop do
      puts say('How many players in game(Range from 1-6):')
      player_num = gets.chomp
      if %w(1 2 3 4 5 6).include?(player_num)
        self.players = init_player(player_num.to_i)
        break
      else
        puts error_prompt('Range should from 1-6!')
      end
    end
    self.dealer = Dealer.new
  end

  def init_player(num)
    count = 1
    name = ''
    money = ''
    players = []
    num.times do
      puts say("For Player#{count}")

      name = set_player_name
      money = set_player_money

      count += 1
      players << Player.new(name, money)
    end
    players
  end

  def set_player_name
    name = ''
    loop do
      puts say('Please input your name:')
      name = gets.chomp

      if name == 'dealer'
        puts error_prompt('Name can not be dealer!')
      elsif !name.empty?
        break
      else
        puts error_prompt('Name can not be null!')
      end
    end
    name
  end

  def set_player_money
    money = ''
    loop do
      puts say("Please input your init money(Not less than #{minimum_bet}):")
      money = gets.chomp
      if money.to_i.to_s != money
        puts error_prompt('Must be digits!')
      elsif money.to_i < minimum_bet
        puts error_prompt("Not less than #{minimum_bet}!")
      else
        money = money.to_i
        break
      end
    end
    money
  end

  # Main game flow
  def start_game
    pre_game
    init_deal
    insurance?
    players_bj
    player_exist?
    players_turn
    player_exist?
    dealer_turn
    compare_points
    play_again?
  end

  # For exchanging and card checking
  def pre_game
    players?
    puts say('Check you chips and put your bet then start the game!')
    deck.check_cards
    exchange_chips
    players?
    players.each do |player|
      player.bet(minimum_bet)
    end
    puts say('All set, game start!')
  end

  # Check whether has player in games
  def players?
    if players.count == 0
      puts say('There are not any players in the game.')
      puts say('Game is over. Thanks')
      exit
    end
  end

  def exchange_chips
    out_list = []
    players.each do |player|
      player.exchange(out_list, minimum_bet)
    end
    out_list.each do |player|
      players.delete(player)
    end
  end

  # Deal first two cards
  def init_deal
    card = {}
    puts say('Deal 2 cards to players and dealer.')
    2.times do |index|
      players.each { |player| player.retrieve_card(deck.deal_card) }
      if index == 1
        card = deck.deal_card
        card.face = 'down'
        dealer.retrieve_card(card)
      else
        dealer.retrieve_card(deck.deal_card)
      end
    end
    players.each { |player| player.show_cards }
    dealer.show_cards
  end

  # Deal insurance situiation
  def insurance?
    if dealer.has_ten_plus?
      unless has_insurance then puts say('None of players bought insurance.') end
      if dealer.dealer_bj?
        puts say('Dealer hit Blackjack!')
        check_players
        puts say('Round is over.')
        play_again?
      else
        puts say('Dealer do not hit Blackjack.')
        players.each do |player|
          player.insurance = false
        end
      end
    end
  end

  # Chek whether players buy insurance
  def has_insurance
    flag = false
      players.each do |player|
        if player.buy_insurance?(dealer.cards[0].value)
          flag = true
        end
      end
    flag
  end

  # Check result of insurance situiation
  def check_players
    players.each do |player|
      if player.insurance && player.points.include?(21)
        player.tie?('bj_insurance')
      elsif player.points.include?(21)
        player.tie?('bj')
      elsif player.insurance
        player.lose?('insurance')
      else
        puts say("#{player.name} do not hit Blackjack. #{player.name} lose bet. Lose for #{player.name}.")
      end
    end
  end

  # Check whether player hit Blackjack
  def players_bj
    players.each do |player|
      player.won?('blackjack')
    end
  end

  # Check whether players in round, if not, start another round
  def player_exist?
    flag = false
    players.each do |player|
      if player.is_complete == false
        flag = true
        break
      end
    end
    unless flag
      puts say('None of players in round.')
      puts say('Round is over.')
      play_again?
    end
  end

  # Include two steps
  def players_turn
    players.each do |player|
      unless player.is_complete then flag = first_action(player) end
      if !player.is_complete && flag == false
        rest_action(player)
      end
    end
  end

  # Split, double, surrender can only trigger in first step
  def first_action(player)
    is_split = false
    turn_over = false
    if player.parent != player
      player.retrieve_card(deck.deal_card)
      is_split = true
    end
    if is_split != true || player.cards[0].value != 'A'
      loop do
        puts say("Hi, #{player.name}.")
        player.show_cards
        puts say('What would you like to do? 1) Hit 2) Stay 3) Split 4) Double 5) Surrender 6) Show ')
        case gets.chomp
        when '1'
          puts say('You choose to hit')
          player.retrieve_card(deck.deal_card)
          if player.is_busted?
            player.lose?('busted')
          end
          break
        when '2'
          puts say('You choose to stay.')
          turn_over = true
          break
        when '3'
          if player.split_max?
            puts say("You can not split(No more than #{Player::SPLIT_MAX} times)!")
          else
            if player.cards_same?
              if player.chips_enough?
                puts say('You choose to split.')
                player.split_card(players)
                player.retrieve_card(deck.deal_card)
                player.parent.split_times += 1
                if player.cards[0].value == 'A'
                  turn_over = true
                  break
                elsif player.cards[0].value == player.cards[1].value
                  is_split = true
                  redo
                else
                  break
                end
              else
                puts say('You do not have enough chips to split!')
              end
            else
              puts say('Your two cards do not have same value!')
            end
          end
        when '4'
          if is_split == true
            puts say('You can not double down after split!')
          elsif !player.chips_enough?
            puts say('You do not have enough chips to double down!')
          else
            puts say('You choose to double down.')
            player.chips -= player.bet_chips
            player.bet_chips *= 2
            player.retrieve_card(deck.deal_card)
            if player.is_busted?
              player.lose?('busted')
              break
            end
            turn_over = true
            break
          end
        when '5'
          if is_split == true
            puts say('You can not surrender after split!')
          else
            puts say('You choose to surrender.')
            player.lose?('surrender')
            turn_over = true
            break
          end
        when '6'
          player.show_cards
          player.show_points
        else
          puts  error_prompt('Input 1 to 6')
        end
      end
    else
      turn_over = true
    end
    turn_over
  end

  # Players can only hit or stay after first step
  def rest_action(player)
    loop do
      puts say("Hi, #{player.name}.")
      player.show_cards
      puts say('What would you like to do? 1) Hit 2) Stay 3) Show')
      case gets.chomp
      when '1'
        puts say('You choose to hit')
        player.retrieve_card(deck.deal_card)
        if player.is_busted?
          player.lose?('busted')
          break
        end
      when '2'
        puts say('You choose to stay.')
        break
      when '3'
        player.show_cards
        player.show_points
      else
        puts  error_prompt('Input 1 to 3')
      end
    end
  end

  def dealer_turn
    dealer.show_cards
    loop do
      if dealer.points.sort.last < 17
        dealer.retrieve_card(deck.deal_card)
        if dealer.is_busted?
          dealer.show_all_cards
          puts say('Dealer busted! Rest of players get extra one bet!')
          players.each do |player|
            unless player.is_complete then player.won?('busted')end
          end
          puts say('Dealer loses the round.')
          puts say('Round is over.')
          play_again?
        end
      else
        puts say('Dealer choose to stay.')
        break
      end
    end
  end

  # Compare total points of gamers
  def compare_points
    dealer.show_all_cards
    players.each do |player|
      unless player.is_complete
        player.show_cards
        player_point = player.points.sort.last
        puts say("#{player.name} got #{player_point}.")
        dealer_point = dealer.points.sort.last
        puts say("Dealer got #{dealer_point}.")
        if player_point > dealer_point
          player.won?('points')
        elsif player_point < dealer_point
          player.lose?('points')
        else
          player.tie?('points')
        end
      end
    end
  end

  # Check whether players would like to play again
  def play_again?
    out_list = []
    players.each do |player|
      if player.parent != player
        out_list << player
        next
      end
      puts say("Hi #{player.name},")
      puts say('Would you like to play again? 1) Yes 2) No')
      loop do
        case gets.chomp
        when '1'
          puts say('Next round is coming soon...')
          break
        when '2'
          puts say('Have a good one.')
          out_list << player
          break
        else
          puts  error_prompt('Input 1 or 2!')
        end
      end
    end
    out_list.each do |player|
      players.delete(player)
    end
    reset
    start_game
  end

  # Reset all status before a new round
  def reset
    dealer.cards = []
    dealer.points = []
    players.each do |player|
      player.cards = []
      player.points = []
      player.bet_chips = 0
      player.insurance = false
      player.is_complete = false
      player.split_times = 0
    end
  end
end

bj = BlackJack.new
bj.run







 