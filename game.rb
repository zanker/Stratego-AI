Dir["./modules/*.rb"].each {|r| require r}

class GameSocket
  ALLOWED_METHODS = ["gamedata", "start_game", "move"]

  def initialize(socket, id)
    @socket = socket
    @session_id = id

    socket.onmessage do |msg|
      puts "REC: #{msg}"
      response = JSON.parse(msg)

      if ALLOWED_METHODS.include?(response["action"])
        self.send("#{response["action"]}", response["data"])
      else
        respond(:error, "Invalid request.")
      end
    end
  end

  def respond(action, data=nil)
    puts "SEN: #{JSON.generate({:action => action, :data => data})}"
    @socket.send(JSON.generate({:action => action, :data => data}))
  end

  # User placed pieces, place ours and start game
  def start_game(temp)
    placement = {}
    temp.each {|k, v| placement[k.to_i] = (v.is_a?(Integer) && v || v.to_sym)}

    # Make sure they aren't placing pieces outside of the game board
    # also make sure they haven't made up a rank
    placement.delete_if {|spot, rank| spot < @game_data[:map][:red][:start] or spot > @game_data[:map][:red][:end] or !@game_data[:pieces][rank]}
    if placement.length != @game_data[:map][:red][:total]
      return respond(:error, "Invalid game data sent back.")
    end

    # Make sure
    totals = placement.values
    @game_data[:pieces].each do |rank, data|
      if totals.count(rank) != data[:avail]
        return respond(:error, "Invalid game data sent back.")
      end
    end

    @game = {:move => :red, :other_player => :blue, :last_fight => {}, :history => []}
    @game[:red] = placement

    # For the time being, will copy the Cyclone Defense and then iprove it once the AI is in
    @game[:blue] = {}
    (@game_data[:map][:blue][:start]..@game_data[:map][:blue][:end]).each do |spot|
      @game[:blue][spot] = @game_data[:templates][:cyclonedef][spot - 1]
    end

    respond(:start, {:move => @game[:move]})

    @movement = Movement.new(@game, @game_data)
    @combat = Combat.new(@game, @game_data)
    @ai = ComputerAI.new(@game, @game_data)
  end

  # Actual game methods
  def move(data)
    data["from"], data["to"] = data["from"].to_i, data["to"].to_i

    # Make sure the move is valid of course
    unless @movement.is_valid?(data["from"], data["to"])
      return respond(:bad_move, {:from => data["from"], :to => data["to"], :move => @game[:move]})
    end

    # Check if we're fighting, as well as the results if we are
    result = @combat.fight(@game[:red][data["from"]], @game[:blue][data["to"]])

    @game[:move] = :blue
    @game[:history].push(:time => Time.now.utc, :from => data["from"], :to => data["to"], :mover => :red, :result => result, :lost_piece => @game[:last_fight][:piece])

    respond(:moved, {:move => @game[:move], :from => data["from"], :to => data["to"], :mover => :red, :result => result, :lost_piece => @game[:last_fight][:piece]})
  end

  def gamedata(mode)
    if data = GAME_DATA[mode.to_sym]
      @game_data = data
      respond(:setup, data)
    else
      respond(:error, "Invalid game mode selected.")
    end
  end
end