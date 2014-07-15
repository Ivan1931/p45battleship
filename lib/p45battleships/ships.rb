module P45battleships

class Ship
  attr_reader :sunk, :type, :hit_status, :points, :name

  def initialize starting_point, direction, length

    raise ArgumentError, "The ship length #{length} is not a valid ship length" unless Ship.is_legal_length? length

    @name = :ship

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

  def intersects_with? ship
    @points.each do |point|
      return true if ship.points.include? point
    end
    false
  end

  def self.valid_ship_type? ship_type 
    Ship.ship_types.any? {|s| ship_type == s }
  end

  def self.raise_invalid_ship_error ship_type 
    raise ArgumentError, "Ship type #{ship_type} does not exist"
  end

  def self.ship_types
    Set.new [:battleship, :carrier, :destroyer, :submarine, :patrol]
  end

  private

  def self.is_legal_length? length
    length >= 1 and length <= 5
  end

end

class Carrier < Ship

  def initialize starting_point, direction
    super(starting_point, direction, 5)
    @name = :carrier
  end

  def length
    5
  end

end

class BattleShip < Ship

  def initialize starting_point, direction
    super(starting_point, direction, 4)
    @name = :battleship
  end

  def length
    4
  end

end

class Destroyer < Ship

  def initialize starting_point, direction
    super(starting_point, direction, 3)
    @name = :destroyer
  end

  def length
    3
  end

end

class Submarine < Ship

  def initialize starting_point, direction
    super(starting_point, direction, 2)
    @name = :submarine
  end

  def length
    2
  end

end

class Patrol < Ship

  def initialize starting_point, direction
    super(starting_point, direction, 1)
    @name = :patrol
  end

  def length
    1
  end

end

end
