#require 'pry'
require 'set'
require_relative 'ships'
require_relative 'grid'


module BattleShipsHelper

  GRID_SIZE = 10

  #this checks if a hash is a valid response
  def valid_response response
  end

  class Point
    attr_reader :x, :y

    def initialize x, y
      @x, @y = x, y
      raise_exception_for_illegal_points! unless self.is_legal?
    end

    def self.new_with_hash *args
      Point.new args[:x], args[:y]
    end

    def destruct
      return @x, @y
    end

    def to_hash
      return {x: @x, y: @y}
    end

    def is_legal?
      @x < GRID_SIZE and @y < GRID_SIZE and
        @x >= 0 and @y >= 0
    end

    def increment direction
      case direction
      when :north
        Point.new @x, @y - 1
      when :south
        Point.new @x, @y + 1
      when :west
        Point.new @x - 1, @y
      when :east
        Point.new @x + 1, @y
      else
        raise ArgumentError, "Direction #{direction} is not recognised"
      end
    end

    def ==(that)
      that.x == @x and that.y == @y
    end

    def self.new_as_random
      x = Random.rand(0..GRID_SIZE)
      y = Random.rand(0..GRID_SIZE)
      Point.new x, y
    end

    private

    def raise_exception_for_illegal_points!
      raise ArgumentError, "The points #{@x}, #{@y} are not legal!"
    end
  end

end

include Ships
include BattleShipsHelper

module GameManagement

  #this is to store data about an opponent


  class GameState
    attr_accessor :opponent, :ships, :agent

    def initialize agent = nil
      @agent = agent
      @ships = []
      init_ship(&method(:init_carrier))
      init_ship(&method(:init_battleship))
      init_ship(&method(:init_destroyer))
      init_ship(&method(:init_submarines))
      init_ship(&method(:init_patrol))
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

    def parse_attack_result result
      { 
        sunk: result['sunk'],
        x: result['x']
        y: result['y']
        hit: result['hit']
      }
    end

    def respond_to_server server_response
      point = Point.new server_response['x'], server_response['y']
      agent.update parse_attack_result(server_response)
      response = attack! point
      response.merge argent.make_decision
    end

    #returns a response object
    def attack! point
      #tripple nestings are very bad
      response = {}
      @ships.each do |ship|
        ship.attack! point
        if ship.is_hit? point
          response[:status] = :hit
          if ship.is_sunk?
            response[:sunk] = ship.class.to_s.downcase.intern
            if self.defeated?
              response[:game_status] = :lost
            end
          end
          return response
        end
      end
      response[:status] = :miss
      response
    end

    def opponent_action point
      response = attack! point
      response.merge agent.decision
    end

    private

    def init_ship &ship_maker
      placed = false
      ships = nil
      until placed
        ships = ship_maker.call()
        placed = true unless ships.any? { |ship| intersects_with_ships? ship }
      end
      @ships = @ships + ships
    end

    def init_carrier
      x = Random.rand(0..GRID_SIZE - 6)
      y = Random.rand(0..GRID_SIZE - 6)
      point = Point.new x, y
      direction = [:east, :south].sample
      [Carrier.new(point, direction)]
    end

    def init_battleship
      x = Random.rand(0..GRID_SIZE - 5)
      y = Random.rand(0..GRID_SIZE - 5)
      point = Point.new x, y
      direction = [:east, :south].sample
      [BattleShip.new(point, direction)]
    end

    def init_destroyer
      x = Random.rand(0..GRID_SIZE - 4)
      y = Random.rand(0..GRID_SIZE - 4)
      point = Point.new x, y
      direction = [:east, :south].sample
      [Destroyer.new(point, direction)]
    end

    def init_submarines
      [1,2].map do 
        x = Random.rand(0..GRID_SIZE - 3)
        y = Random.rand(0..GRID_SIZE - 3)
        point = Point.new x, y
        direction = [:east, :south].sample
        Submarine.new(point, direction)
      end
    end

    def init_patrol
      [1,2].map do 
        x = Random.rand(0..GRID_SIZE - 2)
        y = Random.rand(0..GRID_SIZE - 2)
        point = Point.new x, y
        direction = [:east, :south].sample
        Patrol.new(point, direction)
      end
    end

  end

end
