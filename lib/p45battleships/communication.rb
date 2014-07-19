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
    def run_game 
      attack_result = @player.respond_to_server @initial_nuke
      server_response = nuke attack_result
      until server_says_lost? server_response or @player.defeated?
        attack_result = @player.respond_to_server server_response
        server_response = nuke attack_result unless attack_result.nil? or @player.defeated?
      end
      puts "We defeated them!!!\n#{server_response}\n" if server_says_lost? server_response
      puts "They defeated us!!!\n#{attack_response}\n" if @player.defeated?
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
