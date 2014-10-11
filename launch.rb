require 'pry'
require 'optparse'
require_relative 'lib/p45battleships'
include P45battleships

run_times = 1
host = "localhost:4567"

total = 0

OptionParser.new do |opts|
  opts.on('-r', '--runtimes RUN_TIMES', "Number of times to run script") do |n|
    run_times = n.to_i
  end
  opts.on('-h', '--host HOST', "The address at which to register") do |h|
    host = h
  end
end.parse!

run_times.times do 
  g = Game.new host
  g.register 'jonah.graham.hooper@gmail.com'
  result = g.run_game do |player, our_attack, their_attack|
    puts "Us #{our_attack}"
    puts "Them #{their_attack}"
  end
  total += result[:volleys]
end

puts "Average number of volleys over #{run_times} rounds: #{total / run_times.to_f}"
