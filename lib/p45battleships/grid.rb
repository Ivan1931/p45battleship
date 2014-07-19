module P45battleships
  class Grid

    attr_reader :grid

    def initialize initial_sym = :unknown, grid = nil
      @grid = if grid.nil? then Grid.make_empty_grid(initial_sym) else grid end
    end

    def set_square point, square_type

      def intern_if_string s
        if s.is_a? String
          s.intern
        else 
          s
        end
      end

      square_type = intern_if_string square_type

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

    def place_ship ship
      square_type = ship.name
      ship.points.each do |point|
        set_square point, square_type
      end
      self
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
      square_type == :empty or square_type == :recent_hit or square_type == :hit or square_type == :unknown or Ship.valid_ship_type? square_type
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
