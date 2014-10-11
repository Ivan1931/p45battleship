require 'pry'
require_relative 'lib/p45battleships'
include P45battleships

run_times = ARGV[0].nil? ? 10 : ARGV[0].to_i
host = ARGV[1].nil? ? "localhost:4567" : ARGV[1]
total = 0

run_times.times do 
  g = Game.new host
  g.register 'jonah.graham.hooper@gmail.com'
  result = g.run_game do |player, our_attack, their_attack|
   # puts "Us #{our_attack}"
   # puts "Them #{their_attack}"
  end
  total += result[:volleys]
end

puts "Average number of volleys over #{run_times} rounds: #{total / run_times.to_f}"
