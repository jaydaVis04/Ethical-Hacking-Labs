if ARGV.length != 1
  puts "Usage: ruby ./ruby4.rb filename.html"
  exit
end

filename = ARGV[0]

unless File.exist?(filename)
  puts "File not found: #{filename}"
  exit
end

content = File.read(filename)

converted = content.gsub(/<[^>]+>/) do |tag|
  tag.downcase
end

puts converted

