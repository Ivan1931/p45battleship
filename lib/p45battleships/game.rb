require 'rest_client'
require 'json'

module P45battleships

  class Game
    attr_reader :base_url, :nuke_url, :register_url, :game_id, :history

    def initialize url
      @history = []
      @base_url = url
      @regist_url = "#{url}/register"
      @nuke_url = "#{url}/nuke"
      @player = Player.new StatisticalAgent.new
    end


    #the game communication loop
    def run_game &block
      response_to_server_attack = @player.respond_to_server @initial_nuke
      server_response_to_attack = nuke response_to_server_attack
      @count = 0

      until server_says_lost? server_response_to_attack or @player.defeated?
        @count += 1
        response_to_server_attack = @player.respond_to_server server_response_to_attack
        server_response_to_attack = nuke response_to_server_attack unless response_to_server_attack.nil? or @player.defeated?
        block.call(@player, response_to_server_attack, server_response_to_attack)
      end
      if server_says_lost? server_response_to_attack
        puts "We defeated them\n#{server_response_to_attack}\n" 
        winner = :us
      end

      if @player.defeated?
        puts "They defeated us\n#{response_to_server_attack}\n" 
        winner = :them
      end
      puts "Number of volleys\n#{@count}"
      #binding.pry
      { history: @history, winner: winner, volleys: @count }
    end

    def server_says_lost? response
      response['game_status'] == 'lost'
    end

    def register email
      puts "\nRegistering at #{@regist_url}\n"
      request = { name: 'jonah', email: email } 
      @history << request
      puts "\nSending request\n#{request}\n"
      response = RestClient.post @regist_url, request.to_json, content_type: :json, accept: :json 
      response = JSON.parse response
      puts "\nRequest Recieved\n#{response}\n"
      @game_id = response['id']
      @initial_nuke = response
      response
    end

    #this is a hack to convert the ship names sent by the server to our internal names
    def correct_ship_names response
      def replace_with_lower response, ship
        response.gsub ship, ship.downcase
      end

      ["Submarine", "Battleship", "Destroyer", "Carrier"].each do |ship|
        response = replace_with_lower response, ship
      end

      response.gsub "Patrol Boat", "patrol"
    end

    def go_first
      @initial_nuke = @player.go_first
      run_game
    end

    def nuke game_params
      game_params['id'] = @game_id
      @history << { url: @nuke_url }.merge(game_params)
      response = RestClient.post @nuke_url , game_params.to_json, { content_type: :json, accept: :json }
      response = correct_ship_names(response)
      response = JSON.parse response unless response.nil?
    end

  end

end
