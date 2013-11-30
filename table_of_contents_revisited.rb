title = "Table of Contents"
chapters = [["Getting Started", 1],
            ["Numbers",         9],
            ["Letters",         13]]

puts title.center(50)
puts
chapter_num = 1
chapters.each do |chap|
  name = chap[0]
  page = chap[1]
  beginning = ​'Chapter ' + chapter_num.to_s + ​':' + name
  ending = "page " + page.to_s
  puts beginning.ljust(30) + ending.rjust(20)
  chapter_num = chapter_num + 1
end
