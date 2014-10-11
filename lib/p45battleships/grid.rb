module P45battleships
  class Grid

    attr_reader :grid

    def initialize initial_sym = :unknown, grid = nil
      @grid = if grid.nil? then Grid.make_empty_grid(initial_sym) else grid end
    end

    def set_square point, square_type

      square_type = if square_type.class.to_s == "String" then square_type.intern else square_type end # the class to string thing was done because somehow square type is no longer a string

      normalised_square_type = if square_type == :miss then :empty else square_type end

      Grid.raise_invalid_square_type!(normalised_square_type) unless Grid.valid_square_type? normalised_square_type

      x, y = point.destruct
      @grid[x][y] = normalised_square_type

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

    def place_points points, square_type
      points.each do |point| 
        set_square point, square_type
      end
      self
    end

    def place_ship ship
      ship_type = ship.name
      points = ship.points
      place_points points, ship_type
    end

    def on point, *square_types
      square_types.each { |type| Grid.raise_invalid_square_type! type unless Grid.valid_square_type? type }
      type_at_point = value_for_point point
      square_types.include? type_at_point
    end

    def place_sunk_ship final_hit_point, ship_type
      #Patrol is a trivial case so set it immediately
      if ship_type == :patrol
        set_square final_hit_point, :patrol
        return self
      end

      ship_length = Ship.ship_length ship_type
      incrementations = ship_length - 1

      possible_directions = [:north, :south, :east, :west].select do |direction|
        is_possible = true
        temp_point = final_hit_point
        begin 
          incrementations.times do 
            temp_point = temp_point.increment direction
          end
        rescue
          is_possible = false
        end
        is_possible
      end

      possible_ship_orientations = possible_directions.map do |direction|
        Ship.ship_factory ship_type, final_hit_point, direction
      end

      # A ship can only rest upon an area if all its points are placed
      ships_to_place = possible_ship_orientations.select do |ship|
        ship.points.all? { |point| on(point, :recent_hit, :hit) }
      end

      # The fact that there will alway be at least one ship is invariant based on the fact that we know about the hit

      if ships_to_place.length > 1 # more than one possible ship, we cannot be certain where the ship lies
        ships_to_place.each do |ship|
          place_points ship.points, :likely_ship 
        end
      else ships_to_place.length == 1 # Precisely one ship, we know exactly where it is
        place_ship ships_to_place.first
      end

      return self
    end

    def eliminate_recent_hits
      GRID_SIZE.times do |i|
        GRID_SIZE.times do |j|
          @grid[i][j] = :hit if @grid[i][j] == :recent_hit
        end
      end
    end

    def is_unknown? point
      (value_for_point point) == :unknown
    end

    def self.make_empty_grid initial_sym = :unknown # this makes an empty board with everything on the board considered an unknown
      Array.new(10) { Array.new(10, initial_sym) }
    end

    def self.valid_square_type? square_type
      square_type == :empty or square_type == :recent_hit or square_type == :hit or square_type == :unknown or square_type == :likely_ship or Ship.valid_ship_type? square_type
    end

    def self.raise_invalid_square_type! square_type
      raise ArgumentError, "The square type #{square_type} does not exist"
    end

    def == that
      @grid == that.grid
    end

    def square_type_string square_type
      case square_type
      when :empty
        "E"
      when :unknown
        "?"
      when :hit
        "X"
      when :recent_hit
        "x"
      else
        square_type.to_s[0].upcase
      end
    end

    def to_s
      acc = ""
      @grid.each_with_index do |column, y|
        temp = ""
        column.each_with_index do |square, x|
          temp += square_type_string(grid[x][y]) + "\t"
        end
        temp = temp[0..-2]
        acc += temp + "\n" 
      end
      acc = acc[0..-2]
    end

  end

end
