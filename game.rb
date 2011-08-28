class GameSocket
  ALLOWED_METHODS = ["gamedata", "start_game", "move"]

  def initialize(socket, id)
    @socket = socket
    @session_id = id
    @game = {}

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

    @game[:move] = :red
    @game[:red] = placement

    # For the time being, will copy the Cyclone Defense and then iprove it once the AI is in
    @game[:blue] = {}
    (@game_data[:map][:blue][:start]..@game_data[:map][:blue][:end]).each do |spot|
      @game[:blue][spot] = @game_data[:templates][:cyclonedef][spot - 1]
    end

    respond(:start, {:move => @game[:move]})
  end

  # Actual game methods
  def move(data)

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