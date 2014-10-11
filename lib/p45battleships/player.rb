module P45battleships

  class Player
    attr_accessor :opponent, :ships, :agent

    def initialize agent = nil
      #a seperate opponent is tracked seperatetly from the agent to ensure the game is correctly played
      @opponent = Opponent.new
      @agent = agent
      set_random_ships
    end

    def defeated?
      @ships.empty?
    end

    def intersects_with_ships? other_ship
      @ships.each do |ship|
        unless ship == other_ship
          return true if ship.intersects_with? other_ship
        end
      end
      false
    end

    def parse_attack_info result
      { 
        sunk: result['sunk'],
        x: result['x'],
        y: result['y'],
        hit: result['hit']
      }
    end

    def random_attack
      p = Point.new_as_random
      if @opponent.grid.is_unknown? p
        p
      else
        random_attack
      end
    end

    def go_first
      random_attack
    end

    def get_attack
      result = if @agent
                 choice = @agent.decision
                 if @opponent.grid.is_unknown? choice
                   choice
                 else
                   puts "Randomly attacking, since grid space has already been hit"
                   puts "Choice is #{choice}"
                   puts @agent.opponent.grid
                   puts ("="*10 + "\n") * 2
                   puts @opponent.grid
                   random_attack

                 end
               else
                 random_attack
               end
      @previous_attack = result
      raise ArgumentError, 'This is not a hash!'  if @previous_attack.is_a? Hash
      result.to_hash
    end

    def update_agent server_response
      @agent.update_grid @previous_attack, server_response['status'] if @agent and server_response['status']
      @agent.ship_sunk server_response['sunk'] if server_response['sunk']
    end

    def update_opponent server_response
      @opponent.update @previous_attack, server_response if @previous_attack
    end

    def respond_to_server server_response
        point = Point.new server_response['x'], server_response['y']
        update_opponent server_response
        update_agent server_response if @agent
        response = hit_status_for point
        response.merge get_attack 
    end

    #returns a response object
    def hit_status_for point
      #tripple nestings are very bad
      response = {}
      @ships.each do |ship|
        ship.attack! point
        if ship.is_hit? point
          response[:status] = :hit

          if ship.is_sunk?
            response[:sunk] = ship.name
            @ships.delete ship
          end

          if self.defeated?
            response[:game_status] = :lost
          end
          return response #ensure that we leave the loop here!
        end

      end
      response[:status] = :miss
      response
    end

    private

    def set_random_ships
      @ships = []
      init_ship(&method(:init_carrier))
      init_ship(&method(:init_battleship))
      init_ship(&method(:init_destroyer))
      init_ship(&method(:init_submarine))
      init_ship(&method(:init_submarine))
      init_ship(&method(:init_patrol))
      init_ship(&method(:init_patrol))
    end

    def init_ship &ship_maker
      placed = false
      ship = nil
      until placed
        ship = ship_maker.call()
        placed = !(intersects_with_ships? ship)
      end
      @ships << ship
    end

    def init_carrier
      x = Random.rand(0..GRID_SIZE - 5)
      y = Random.rand(0..GRID_SIZE - 5)
      point = Point.new x, y
      direction = [:east, :south].sample
      Carrier.new(point, direction)
    end

    def init_battleship
      x = Random.rand(0..GRID_SIZE - 4)
      y = Random.rand(0..GRID_SIZE - 4)
      point = Point.new x, y
      direction = [:east, :south].sample
      BattleShip.new(point, direction)
    end

    def init_destroyer
      x = Random.rand(0..GRID_SIZE - 3)
      y = Random.rand(0..GRID_SIZE - 3)
      point = Point.new x, y
      direction = [:east, :south].sample
      Destroyer.new(point, direction)
    end

    def init_submarine
      x = Random.rand(0..GRID_SIZE - 2)
      y = Random.rand(0..GRID_SIZE - 2)
      point = Point.new x, y
      direction = [:east, :south].sample
      Submarine.new(point, direction)
    end

    def init_patrol
      x = Random.rand(0..GRID_SIZE - 1)
      y = Random.rand(0..GRID_SIZE - 1)
      point = Point.new x, y
      direction = [:east, :south].sample
      Patrol.new(point, direction)
    end

  end

  def to_s
    g = Grid.new :empty
    @ships.each { |ship| g = g.place_ship ship }
    g.to_s
  end

end
