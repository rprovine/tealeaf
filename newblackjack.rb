h = "\u{2665}"
s = "\u{2660}"
d = "\u{2666}"
c = "\u{2663}"

suits = [h,s,d,c]
rank = [2,3,4,5,6,7,8,9,10,'J','Q', 'K', 'A']

#dealer will always be last player.
$players_hand = [[],[],[],[]]
deck = []
# Fill the deck
suits.each do |suit|
        rank.each do |r|
                deck.push((r.to_s + suit.to_s))
        end
end

$shuffled_deck = deck.shuffle

def deal_cards                
        2.times do        
                $players_hand.each do |hand|
                        hand.push($shuffled_deck.pop)
                end        
        end
end

### deal the cards
#deal_cards


### Create some numbers we can work with from the players_hand array. Strip the suit and convert ranks.
$simple_hand = []
def remove_suits
i = 0
        $players_hand.each do |hand|
                $simple_hand.push([])
                hand.each do |cards|
                        card = cards[0..-2]
                        if card == 'J' || card == 'Q' || card == 'K'
                                card = 10
                        end
                        if card == 'A'
                                card = 11
                        end
                        $simple_hand[i].push card
                end
        i= i + 1
        end
end


### Get real numbers for hand values
$current_count = []
def do_counts
        $simple_hand.each do |hand|
                ace = 0
                total = 0
                hand.each do |card|
                        if card.to_i == 11
                                ace = ace + 1
                        end
                        total = total + card.to_i
                        while total > 21 && ace > 0
                                total = total - 10
                                ace = ace - 1
                        end 
                end
                $current_count.push(total)
        end
end


# # ### i is for the turns to iterate over players properly
def hit_stay i
        $current_count = []
        puts 'The dealer is showing the ' + $players_hand[-1][0].to_s + '.'
        puts 'Player ' + i.to_s
        puts 'Your hand is ' + $players_hand[(i-1)].to_s
        puts 'Would you like to hit or stand?'
        answer = gets.chomp.downcase
        if answer == 'hit'
                $players_hand[(i-1)].push($shuffled_deck.pop.to_s)
                puts 'You received the ' + $players_hand[(i-1)][-1].to_s
                $simple_hand = []
                remove_suits
                do_counts
                puts 'Your current count is ' + $current_count[(i-1)].to_s
                if $current_count[(i-1)] > 21
                        puts 'You busted!'
                        return
                end
                hit_stay i
        elsif answer == 'stand'
                $simple_hand = []
                remove_suits
                do_counts
                puts 'The player stands with ' + $current_count[(i-1)].to_s
                return

        else
                puts ''
                puts 'ERROR: Type "hit" or "stand".'
                puts ''
                hit_stay i
        end
end        

        

def turns 
        i = 1
        while i < $players_hand.length
        puts 'Player ' + i.to_s + ' it is your turn.'
         hit_stay i
         i = i + 1
         end 
end



def dealer_turn
        $simple_hand = []
        remove_suits
        do_counts
        puts 'The dealer\'s hand is ' + $players_hand[-1].to_s
        if $current_count[-1] < 17
                $players_hand[-1].push($shuffled_deck.pop.to_s)
                puts 'The dealer hits and receives ' + $players_hand[-1][-1].to_s
                dealer_turn
        elsif $current_count[-1] >= 17 && $current_count[-1] < 22
                puts 'The dealer stands with ' +$current_count[-1].to_s
        else
                puts 'The dealer busted.'
        end
end


def win_lose
        $current_count = []
        $simple_hand = []
        remove_suits
        do_counts
        i = 1
        dealer = $current_count[-1]
        $current_count.each do |player|
                def scores (dealer, player, i)
                        puts ''
                        puts 'The dealer had ' + $players_hand[-1].to_s + ' for ' + dealer.to_s
                        puts' The player had ' + $players_hand[(i-1)].to_s + ' for ' + player.to_s
                end
                if i < $current_count.length
                        if player < 22 && player > dealer || player < 22 && dealer > 21
                                scores dealer, player, i
                                puts 'Player ' + i.to_s + ' WINS!'
                                puts ''
                                i = i + 1
                        elsif player == dealer && player < 22
                                scores dealer, player, i
                                puts 'Player ' + i.to_s + ' pushes.'
                                puts ''
                                i = i + 1
                        else
                                scores dealer, player, i
                                puts 'Player ' + i.to_s + ' loses.'
                                puts ''
                                i = i + 1
                        end
                end
        end
end

### play your game 
deal_cards
remove_suits
turns
dealer_turn
win_lose