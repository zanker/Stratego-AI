class GameSocket
  ALLOWED_METHODS = ["gamedata"]

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

  def respond(action, data)
    puts "SEN: #{JSON.generate({:action => action, :data => data})}"
    @socket.send(JSON.generate({:action => action, :data => data}))
  end

  # Actual game methods
  def gamedata(mode)
    if data = GAME_DATA[mode.to_sym]
      respond(:setup, data)
    else
      respond(:error, "Invalid game mode selected.")
    end
  end
end