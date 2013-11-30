  puts "Hey there my awesome grandchild, how are you doing?"
  while true
    comment = gets.chomp
  if comment == "BYE"
    puts "BYE MY GRANDCHILD"
    break
  end

  if comment != comment.upcase
    puts "YOU ARE WAY TOO SOFT, I LOST MY HEARING.  PLEASE REPEAT!"
  else 
    random_year = 1930 + rand(21)
    puts "NO, NOT SINCE " + random_year.to_s + "!"
  end
end