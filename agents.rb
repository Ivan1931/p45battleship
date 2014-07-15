module Agent

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
      @grid.set_square point, attack_result
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
end
