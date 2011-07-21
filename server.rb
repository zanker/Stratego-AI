require "rubygems"
require "eventmachine"
require "em-websocket"
require "redis"
require "json/ext"
require "./game"

GAME_DATA = {}
Dir["./data/*.rb"].each {|f| require f}

puts "Loaded server"

unique_id = 1

EventMachine.run do
  EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 5000) do |ws|
    GameSocket.new(ws, unique_id)
    unique_id += 1
  end
end