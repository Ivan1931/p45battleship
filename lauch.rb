require 'pry'
require_relative 'lib/p45battleships'
include P45battleships

g = Game.new ARGV[0]
g.register 'jonah.graham.hooper@gmail.com'
g.run_game do |player, our_attack, their_attack|
  puts "Us #{our_attack}"
  puts "Them #{their_attack}"
end

