#require 'pry'
require 'set'
require_relative 'ships'

include Ships

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

class Grid

  attr_reader :grid

  def initialize initial_sym = :unknown, grid = nil
    @grid = if grid.nil? then Grid.make_empty_grid(initial_sym) else grid end
  end

  def set_square point, square_type
    Grid.raise_invalid_square_type!(square_type) unless Grid.valid_square_type? square_type

    x, y = point.destruct
    @grid[x][y] = square_type

    self
  end

  def can_place_ship? ship, allowed_square_type = [:unknown]
    !ship.points.map do |point|
      val = value_for_point point
      allowed_square_type.include? val
    end.include?(false)
  end

  def value_for_point point
    x, y = point.destruct
    @grid[x][y]
  end

  def self.make_empty_grid initial_sym = :unknown # this makes an empty board with everything on the board considered an unknown
    Array.new(10) { Array.new(10, initial_sym) }
  end

  def self.valid_square_type? square_type
    square_type == :empty or square_type == :recent_hit or square_type == :hit or square_type == :unknown
  end

  def self.raise_invalid_square_type! square_type
    raise ArgumentError, "The square type #{square_type} does not exist"
  end


end

class GameState
  attr_accessor :opponent, :ships

  def initialize 
  end

end
