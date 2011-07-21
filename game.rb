class GameSocket
  ALLOWED_METHODS = ["gamedata", "start_game"]

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

    # Double check the data to make sure nothing funky is going on
    placement.delete_if {|spot, rank| spot < @game_data[:map][:red][:start] or spot > @game_data[:map][:red][:end]}
    if placement.length != @game_data[:map][:red][:total]
      respond(:error, "Invalid game data sent back.")
    end

    totals = placement.values
    @game_data[:pieces].each do |rank, data|
      if totals.count(rank) != data[:avail]
        respond(:error, "Invalid game data sent back.")
        return
      end
    end

    # Save theres
    @game[:red] = placement

    # Figure out ours

    respond(:start)
  end

  # Actual game methods
  def gamedata(mode)
    if data = GAME_DATA[mode.to_sym]
      @game_data = data
      respond(:setup, data)
    else
      respond(:error, "Invalid game mode selected.")
    end
  end
end