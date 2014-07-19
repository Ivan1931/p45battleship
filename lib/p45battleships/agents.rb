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


    # allowed squares are squares upon which a ship can rest its hull

    def make_heat_map allowed_squares, heat_map = {}

      increment_heat_map_points = lambda do |points|
        points.each do |point|
          p = point.to_hash
          if heat_map.has_key? p
            heat_map[p] += 1
          else
            heat_map[p] = 1
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
        #puts "\nShip: #{ship_type}"
        #puts "Direction: #{direction}"
        place_holder_point = Point.origin
        test_ship = Ship.ship_factory ship_type, Point.origin, :east
        (0..GRID_SIZE - test_ship.length - 1).each do 
          ship_start = Point.new_from_point place_holder_point

          (GRID_SIZE).times do
            temp_ship = Ship.ship_factory ship_type, ship_start, direction
            increment_heat_map_points.call temp_ship.points if @opponent.grid.can_place_ship? temp_ship, allowed_squares
            #puts ship_start.to_s
            begin
              ship_start = ship_start.increment (invert_direction.call direction)
            rescue ArgumentError
            end
          end

          place_holder_point = place_holder_point.increment direction
        end
      end

      @opponent.possible_ships.keys.each do |ship_type| 
        count_possible_placements.call ship_type, :east
        count_possible_placements.call ship_type, :south
      end

      return heat_map
    end


    def hunt_mode
      make_heat_map([:unknown]).max_by { |point, temp| temp }[0]
    end

    def target_mode
      (make_heat_map [:unknown, :recent_hit], (make_heat_map [:unknown])).max_by { |point, temp| temp }[0]
    end

    def decision

      heat_map_best_choice = if @mode == :hunt
                               hunt_mode
                             else
                               target_mode
                             end

      r = Point.new heat_map_best_choice[:x], heat_map_best_choice[:y]
      puts r.to_s
      r
    end

    def ship_sunk ship_type
      super ship_type
      @opponent.grid.eliminate_recent_hits
      @mode = :hunt
    end

    def update_grid point, attack_result
      if attack_result == :hit and @mode == :hunt
        @mode = :target
        attack_result = :recent_hit
      end
      super point, attack_result
    end

  end

end
