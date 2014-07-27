require 'set'

module P45battleships

  GRID_SIZE = 10

  class Point
    attr_reader :x, :y

    def initialize x, y
      @x, @y = x, y
      raise_exception_for_illegal_points! unless self.is_legal?
    end

    def self.new_with_hash args
      Point.new args[:x], args[:y]
    end

    def self.new_as_random
      Point.new(Random.rand(0..GRID_SIZE - 1), Random.rand(0..GRID_SIZE - 1))
    end

    def self.new_from_point point
      Point.new point.x, point.y
    end

    def self.origin
      Point.new 0, 0
    end

    def destruct
      return @x, @y
    end

    def to_hash
      return {x: @x, y: @y}
    end

    def to_s
      "x: #{@x}, y: #{@y}"
    end

    def is_legal? x = @x, y = @y
      x < GRID_SIZE and y < GRID_SIZE and
        x >= 0 and y >= 0
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
