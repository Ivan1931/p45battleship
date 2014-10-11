require 'pry'
require_relative 'lib/p45battleships'
include P45battleships

host = ARGV[0].nil? ? "localhost:4567" : ARGV[0]
g = Game.new host
g.register 'jonah.graham.hooper@gmail.com'
g.run_game do |player, our_attack, their_attack|
  puts "Us #{our_attack}"
  puts "Them #{their_attack}"
end

