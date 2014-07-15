require_relative 'game_state'

require 'rest_client'
require 'json'

include GameState

class Communicator
  attr_reader :base_url, :nuke_url, :register_url, :game_id, :history

  def initialize url
    @history = []
    @base_url = url
    @regist_url = "#{@url}/register"
    @nuke_url = "#{@url}/nuke"
    
    response = register 'jonah@example.com'
    @game_id = response['id']

    run_game response
  end

  #the game communication loop
  def run_game initial_nuke
    game_state = GameState.new
    attack_result = game_state.respond_to_server initial_nuke
    server_response = nuke attack_result
    until server_says_lost? server_response or game_state.has_lost?
      attack_result game_state.respond_to_server server_response
      server_response = nuke attack_result
    end
  end

  def server_says_lost? response
    response['game_status'] == 'lost'
  end

  def register email
    request_json = { url: @regist_url, email: email } 
    @history << request_json
    response = RestClient.get @regist_url, request_json.to_json, content_type: :json, accept: :json
    JSON.parse response.body
  end

  def nuke game_params
    game_params['id'] = @game_id
    @history << { url: @nuke_url }.merge(game_params)
    response = RestClient.post @nuke_url , game_params, content_type: :json, accept: :json
    JSON.parse response.body
  end

end
