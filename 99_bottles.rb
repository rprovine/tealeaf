starting_num = 99
current_num = starting_num
  while current_num > 2
    puts current_num.to_s + " bottles of beer on the wall, " + current_num.to_s + " bottles of beer!"
    current_num = current_num - 1
    puts "Take one down, pass it around" + current_num.to_s + " bottles of beer on the wall!"
  end

  puts "2 bottles of beer on the wall, 2 bottles of beer!"
  puts "Take one down, pass it around, 1 bottle of beer on the wall!"
  puts  "1 bottle of beer on the wall, 1 bottle of beer!"
  puts  "Take one down, pass it around, no more bottles of beer on the wall!"
  