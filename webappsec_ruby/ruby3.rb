freq = Hash.new(0)

lines = File.readlines("abc.txt")
words = lines.first.split

words.each do |word|
  freq[word] += 1
end

freq.each do |k, v|
  puts "#{k} => #{v}"
end
