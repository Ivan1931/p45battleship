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
    allowed_square_type.each { |type| Grid.raise_invalid_square_type!(type) unless Grid.valid_square_type? type }
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

