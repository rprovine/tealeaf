puts "Please enter some words and I will sort them for you:"
words = []

while true
  word = gets.chomp
  if word == ""
    break
  end
  words.push word
end

puts "Thank you.  Here are the words in a sorted fashion:"
puts words.sort


