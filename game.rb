class GameSocket
  ALLOWED_METHODS = [:newgame]

  def initialize(socket, id)
    @socket = socket
    @session_id = id

    socket.onmessage do |msg|
      puts "REC: #{msg}"
      response = JSON.parse(msg)
      respond(:error, "Invalid request.")

      self.send("#{response["action"]}", msg)
    end
  end

  def respond(action, data)
    puts "SEN: #{JSON.generate({:action => action, :data => data})}"
    @socket.send(JSON.generate({:action => action, :data => data}))
  end

  # Actual game methods
  def newgame

  end
end