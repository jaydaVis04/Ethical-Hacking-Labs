my_arr = Array.new
#INITIALIZATION
i=0
until my_arr.length()==1000 do
  i+=1
  my_arr.push(i)
end

#FOR LOOP
for x in my_arr
  puts "#{x} is in the array"
end

#WHILE LOOP
while !my_arr.empty? do
  puts "#{my_arr.first}"
  my_arr.shift
end

#ITERATOR
my_arr.each { |number| puts number}
