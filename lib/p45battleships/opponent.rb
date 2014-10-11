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

end
