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
      until server_says_lost? server_response_to_attack or @player.defeated?
        response_to_server_attack = @player.respond_to_server server_response_to_attack
        server_response_to_attack = nuke response_to_server_attack unless response_to_server_attack.nil? or @player.defeated?
        block.call(response_to_server_attack, server_response_to_attack)
      end
      puts "We defeated them!!!\n#{server_response_to_attack}\n" if server_says_lost? server_response_to_attack
      puts "They defeated us!!!\n#{attack_response}\n" if @player.defeated?
      #binding.pry
      @history
    end

    def server_says_lost? response
      response['game_status'] == 'lost'
    end

    def register email
      puts "\nRegistering at #{@regist_url}\n"
      request = { name: 'jonah', email: email } 
      @history << request
      puts "\nProcessing request #{request}\n"
      response = RestClient.post @regist_url, { data: request.to_json }, { content_type: :json, accept: :json }
      puts "\nRequest Processed #{request}\n"
      response = JSON.parse response
      @game_id = response['id']
      @initial_nuke = response
      response
    end

    def go_first
      @initial_nuke = @player.go_first
      run_game
    end

    def nuke game_params
      game_params['id'] = @game_id
      @history << { url: @nuke_url }.merge(game_params)
      puts "\nWe are nuking Nuking #{game_params.to_json}\n"
      response = RestClient.post @nuke_url , game_params.to_json, { content_type: :json, accept: :json }
      puts "\nTheir Counter nuke: #{response.body}\n"
      JSON.parse response.body unless response.body.nil?
    end

  end

end
