require 'yaml'

module P45battleships

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
      Ship.raise_invalid_ship_error ship_type unless Ship.valid_ship_type? ship_type
      @possible_ships[ship_type] -= 1
    end

    def attack point, attack_result
      x, y = point.destruct
      if attack_result == :miss
        attack_result = :empty
      end
      @grid.set_square point, attack_result
    end

    def update previous_point, response_from_server
      status = response_from_server['status'].intern if response_from_server['status']
      attack previous_point, status if status and previous_point

      if response_from_server['sunk']
        ship_symbol = response_from_server['sunk'].intern
        ship_sunk ship_symbol
      end
    end

    def remaining_ships
      @possible_ships.map { |k, v| k if v > 0 }.select { |a| !a.nil? }
    end

  end

  class Agent
    attr_reader :opponent

    def initialize
      @opponent = Opponent.new
    end

    def decision
    end

    def ship_sunk ship_type
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
    end

    def get_move_from_heat_map heat_map
      heat_map = heat_map.select { |k, v| @opponent.grid.is_unknown?(Point.new_with_hash k) }

      puts project_heat_map heat_map

      return heat_map.max_by { |k, v| v }[0]
    end

    def project_heat_map heat_map
      temp = Array.new(GRID_SIZE) { Array.new(GRID_SIZE, "X") }
      heat_map.each do |k, v|
        x = k[:x]
        y = k[:y]
        temp[x][y] = "#{v.round(3)}"
      end
      temp = temp.map do |s|
        s.join "\t"
      end
      temp.join "\n"
    end

    # allowed squares are squares upon which a ship can rest its hull

    def make_heat_map allowed_squares, heat_map = {}


      increment_heat_map_points = lambda do |points|

        if @mode == :target and points.any? { |point| @opponent.grid.value_for_point(point) == :recent_hit }
          inc = 2
        else
          inc = 1
        end

        points.each do |point|
          p = point.to_hash
          if heat_map.has_key? p
            heat_map[p] += inc
          else
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

      count_possible_placements = lambda do |ship_type, direction|

        place_holder_point = Point.origin
        test_ship = Ship.ship_factory ship_type, Point.origin, :east

        outer_iterations = GRID_SIZE - test_ship.length - 1

        outer_iterations.times do 
          ship_start = Point.new_from_point place_holder_point

          GRID_SIZE.times do
            temp_ship = Ship.ship_factory ship_type, ship_start, direction
            if @opponent.grid.can_place_ship? temp_ship, allowed_squares
              increment_heat_map_points.call temp_ship.points
            end

            begin #to remove the error at the last iteration
              ship_start = ship_start.increment (invert_direction.call direction)
            rescue ArgumentError
            end
          end

          place_holder_point = place_holder_point.increment direction
        end
      end

      @opponent.possible_ships.keys.each do |ship_type| 
        @opponent.possible_ships[ship_type].times do 
          count_possible_placements.call ship_type, :east
          count_possible_placements.call ship_type, :south
        end
      end


      return heat_map
    end


    def hunt_mode
      get_move_from_heat_map(make_heat_map([:unknown, :hit]))
    end

    def target_mode
      get_move_from_heat_map(make_heat_map [:unknown, :recent_hit, :recent_hit])
    end

    def decision

      heat_map_best_choice = if @mode == :hunt
                               hunt_mode
                             else
                               target_mode
                             end

      Point.new heat_map_best_choice[:x], heat_map_best_choice[:y]
    end

    def ship_sunk ship_type
      super ship_type
      @opponent.grid.eliminate_recent_hits
      @mode = :hunt
    end

    def update_grid point, attack_result
      puts "attack_result #{attack_result}"
      if attack_result.intern == :hit
        puts "======> Target mode <=======\n"
        @mode = :target
        attack_result = :recent_hit
      end
      super point, attack_result
    end

  end

end
