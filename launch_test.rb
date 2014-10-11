require 'pry'
require_relative 'lib/p45battleships'
include P45battleships

victory_rates = 0
trials = if ARGV[1].nil? then 10 else ARGV[1].to_i end

trials.times do 
  g = Game.new ARGV[0]
  g.register 'jonah.graham.hooper@gmail.com'
  result = g.run_game do |player, our_attack, their_attack|
  end
  victory_rates += result[:volleys]
end

puts "The average number of moves over #{trials} trials was #{(victory_rates/10.0).round(3)}"

