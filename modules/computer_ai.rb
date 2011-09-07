module Game
  class ComputerAI
    def initialize(game, game_data)
      @game, @game_data = game, game_data
      @enemy_pieces = {}
    end

    def play

    end

    # The AI works under the assumption of a human with perfect memory.
    # It will cheat when it has the info, but it won't proactively cheat
    def cheat(old_spot, spot, rank)
      self.dead(old_spot) if old_spot
      @enemy_pieces[spot] = rank
    end

    def dead(spot)
      @enemy_pieces.delete(spot)
    end

    def cheating?(spot)
      !!@enemy_pieces[spot]
    end
  end
end