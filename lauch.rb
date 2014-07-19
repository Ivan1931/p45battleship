require 'pry'
require_relative 'lib/p45battleships'
include P45battleships

g = Game.new 'localhost:4567'
g.register ''
g.run_game do |our_attack, their_attack|
  puts "Us #{our_attack}"
  puts "Them #{their_attack}"
end

