require 'pry'

module BattleShipsHelper


  GRID_SIZE = 10

  class Point
    attr_reader :x, :y

    def initialize x, y
      @x, @y = x, y
      raise_exception_for_illegal_points! unless self.is_legal?
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
  attr_reader :sunk, :points, :type, :hit_status

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
      @hit_status[starting_point.to_hash] = false
    end

  end

  def is_hit? point
  end

  def attack! point
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
  attr_accessor :ships
  attr_reader :grid

  def initialize initial_symbol
    
  end
end

class Player
  attr_accessor :opponent_grid, :grid

  def initialize

  end

end
