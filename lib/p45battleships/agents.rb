require 'yaml'
require 'pry'

module P45battleships

  class Agent
    attr_reader :opponent

    def initialize
      @opponent = Opponent.new
    end

    def decision
    end

    def ship_sunk ship_type
      ship_type = Ship.convert_to_ship_symbol ship_type if ship_type.is_a? String
      @opponent.ship_sunk ship_type
    end

    def update_grid point, attack_result
      @opponent.attack point, attack_result
    end

  end

  class StatisticalAgent < Agent
    def initialize
      super
      @mode = :hunt
      @hits = 0
      @hits_since_last_sunk = []
    end

    def get_move_from_heat_map heat_map
      ret = heat_map.select { |k, v| @opponent.grid.is_unknown?(Point.new_with_hash k) }
      ret.max_by { |k, v| v }[0]
    end

    def project_heat_map heat_map # converts a heat map string
      temp = Array.new(GRID_SIZE) { Array.new(GRID_SIZE, "X") }
      heat_map.each do |k, v|
        x = k[:x]
        y = k[:y]
        temp[y][x] = "#{v.round(3)}"
      end
      temp = temp.map do |s|
        s.join "\t"
      end
      temp.join "\n"
    end

    # allowed squares are squares upon which a ship can rest its hull

    def make_heat_map allowed_squares, heat_map = {}

      score_point = lambda do |point|
        case @opponent.grid.value_for_point point
        when :unknown 
          1.0
        when :empty 
          0.0
        when :recent_hit 
          4.0
        when :hit 
          0.2
        end
      end

      increment_heat_map_points = lambda do |points|
        inc = points.map(&score_point).reduce(:+) / points.size.to_f
        points.each do |point|
          p = point.to_hash
          if heat_map.has_key? p
            heat_map[p] += inc
          elsif @opponent.grid.is_unknown? point
            heat_map[p] = inc
          end
        end
      end

      invert_direction = lambda do |direction|
        case direction
        when :east
          :south
        else 
          :east
        end
      end

      #Produces a list of possible starting points for a ship
      possible_starting_points = []
      GRID_SIZE.times do |i|
        GRID_SIZE.times do |j|
          p = Point.new i, j
          possible_starting_points << p if allowed_squares.include? @opponent.grid.value_for_point p
        end
      end

      count_possible_placements = lambda do |ship_type, direction|
        #now iterate through starting points and see if ships can be placed
        possible_starting_points.each do |ship_start|
          continue = true
          begin
            temp_ship = Ship.ship_factory ship_type, ship_start, direction
            if @opponent.grid.can_place_ship? temp_ship, allowed_squares
              increment_heat_map_points.call temp_ship.points
            end
          rescue ArgumentError
          end
        end
      end

      @opponent.possible_ships.keys.each do |ship_type| 
        @opponent.possible_ships[ship_type].times do 
          count_possible_placements.call ship_type, :east
          count_possible_placements.call ship_type, :south
        end
      end

     # puts @opponent.grid.to_s
     # puts ""
     # puts (project_heat_map heat_map)

      #puts @opponent.remaining_ships.length.to_s

      return heat_map
    end

    def decision
      heat_map_best_choice = get_move_from_heat_map(make_heat_map [:unknown, :hit, :recent_hit])
      Point.new heat_map_best_choice[:x], heat_map_best_choice[:y]
    end

    def ship_sunk ship_type
      @hits_since_last_sunk.each do |point|
        @opponent.attack point, :hit
      end
      length = Ship.ship_length ship_type.intern
      length.times do
        @hits_since_last_sunk.pop
      end
      super ship_type
    end

    def update_grid point, attack_result
      if attack_result.intern == :hit
        @hits += 1
        @hits_since_last_sunk << point
        attack_result = :recent_hit
      end
      super point, attack_result
    end

  end

end
