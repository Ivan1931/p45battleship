#require 'pry'
require 'set'
require_relative 'ships'
require_relative 'grid'


module BattleShipsHelper

  GRID_SIZE = 10

  class Point
    attr_reader :x, :y

    def initialize x, y
      @x, @y = x, y
      raise_exception_for_illegal_points! unless self.is_legal?
    end

    def self.new_with_hash *args
      Point.new args[:x], args[:y]
    end
    
    def destruct
      return @x, @y
    end

    def to_hash
      return {x: @x, y: @y}
    end

    def is_legal?
      @x < GRID_SIZE and @y < GRID_SIZE and
      @x >= 0 and @y >= 0
    end

    def increment direction
      case direction
      when :north
        Point.new @x, @y - 1
      when :south
        Point.new @x, @y + 1
      when :west
        Point.new @x - 1, @y
      when :east
        Point.new @x + 1, @y
      else
        raise ArgumentError, "Direction #{direction} is not recognised"
      end
    end

    def ==(that)
      that.x == @x and that.y == @y
    end

    private

    def raise_exception_for_illegal_points!
      raise ArgumentError, "The points #{@x}, #{@y} are not legal!"
    end
  end
  
end

include Ships
include BattleShipsHelper

#this is to store data about an opponent
class Opponent
  attr_accessor :grid, :possible_ships 

  def initialize
    @possible_ships = {}
    @possible_ships[:carrier] = 1
    @possible_ships[:battleship] = 1
    @possible_ships[:destroyer] = 1
    @possible_ships[:submarine] = 2
    @possible_ships[:patrol] = 2

    @grid = Grid.new :unknown
  end

  def ship_sunk ship_type
  end

  def target point
  end

end


class GameState
  attr_accessor :opponent, :ships

  def initialize 
  end

end
