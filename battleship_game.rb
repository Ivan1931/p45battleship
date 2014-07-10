#require 'pry'

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

class Ship
  attr_reader :sunk, :type, :hit_status

  def initialize starting_point, direction, length

    raise ArgumentError, "The ship length #{length} is not a valid ship length" unless Ship.is_legal_length? length

    @sunk = false

    @points = Array.new(length)
    @points[0] = starting_point

    @hit_status = {}
    @hit_status[starting_point.to_hash] = false

    temp_point = starting_point
    iterations = length - 1

    iterations.times do |i|
      temp_point = temp_point.increment direction
      @points[i + 1] = temp_point
      @hit_status[temp_point.to_hash] = false
    end

  end

  def points
    @hit_status.keys
  end

  def is_hit? point
    point_hash = point.to_hash
    @hit_status[point_hash] == true
  end

  def attack! point
    point_hash = point.to_hash
    if @hit_status.has_key?(point_hash)
      @hit_status[point_hash] = true
    end
    self
  end

  def is_sunk?
    @hit_status.values.all? {|elem| elem }
  end

  private

  def self.is_legal_length? length
    length >= 1 and length <= 5
  end

end

class Carrier < Ship

  def initialize starting_point, direction
    super(starting_position, direction, 5)
  end

  def length
    5
  end
end

class BattleShip < Ship

  def initialize starting_point, direction
    super(starting_position, direction, 4)
  end

  def length
    4
  end
end

class Destroyer < Ship

  def initialize starting_point, direction
    super(starting_position, direction, 3)
  end

  def length
    3
  end
end

class Submarine < Ship

  def initialize starting_point, direction
    super(starting_position, direction, 1)
  end

  def length
    2
  end
end

class Patrol < Ship

  def initialize starting_point, direction
    super(starting_position, direction, 5)
  end

  def length
    1
  end
end

class Grid

  attr_reader :grid

  def initialize(initial_sym = :unknown, grid = nil)
    @grid = if grid.nil? then Grid.make_empty_grid(initial_sym) else grid end
  end

  def set_ship(x, y, ship_type, direction)
    increment_function = -> (a, b) do
      case direction
      when :north
        return a, b - 1
      when :south
        return a, b + 1
      when :east
        return a + 1, b
      when :west
        return a - 1, b
      end
    end

    ship_length(ship_type).times do 
      self.set_square x, y, ship_type
      x, y = increment_function.call x, y
    end

    self
  end

  def set_square(x, y, ship_type)
    Grid.raise_out_of_grid!(x, y) if Grid.out_of_grid?(x, y)
    grid[x][y] = ship_type
    self
  end

  def self.make_empty_grid(initial_sym = :unknown) # this makes an empty board with everything on the board considered an unknown
    Array.new(10) { Array.new(10, initial_sym) }
  end

  def self.out_of_grid?(x, y)
    x >= GRID_SIZE or y >= GRID_SIZE or x < 0 or y < 0
  end

  def self.raise_out_of_grid!(x, y)
    raise ArgumentError, "Position #{x}, #{y} are outside of the posible bounds of the grid"
  end

  def count_destroyed_ships(ship_type)
  end

end


class Opponent
  attr_accessor :grid, :possible_ships
  def initialize
  end
end

class GameState
  attr_accessor :opponent, :ships

  def initialize

  end

end
