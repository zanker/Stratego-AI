module Game
  class Cient
    def initialize(combat, movement, game, game_data)
      @combat, @movement, @game, @game_data = combat, movement, game, game_data
    end

    def move(from, to)
      return false unless @movement.move(@game[:move], from, to)
      mover, defender = @game[:move], flip_side(@game[:move])

      if @game[defender][to]
        result = @combat.fight(mover, @game[mover][from], @game[defender][to])
        @game[:history].push(:time => Time.now.utc, :from => from, :to => to, :mover => @game[:move], :result => result[:status], :lost_pieces => result[:pieces], :defender => result[:defender])
      else
        @game[:history].push(:time => Time.now.utc, :from => from, :to => to, :mover => @game[:move], :result => :moved, :reveal => @movement.force_reveal? && @game[mover][to])
      end

      @game[:move] = defender
    end

    def flip_side(side)
      side == :blue && :red || :blue
    end
  end
end