require 'sinatra'
require 'json'
require_relative '../lib/p45battleships'

include P45battleships

get '/' do

end

post '/test', provides: :json do
  content_type :json
  r = JSON.parse request.body.read
  {hello: :world}.merge(r).to_json
end

post '/register', provides: :json do
  content_type :json
  @@player = Player.new
  @@player.random_attack.to_hash.to_json
end

post '/nuke', provides: :json do
  content_type :json
  #puts "\nRequest body: #{request.body.read}\n"
  r = JSON.parse request.body.read
  @@player.respond_to_server(r).to_json
end
