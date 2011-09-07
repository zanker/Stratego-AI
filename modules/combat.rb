module Game
  class Combat
    def initialize(game, game_data)
      @game, @game_data = game, game_data
    end

    def fight(agg_side, def_side, spot)
      agg_rank, def_rank = @game[agg_side][spot], @game[def_side][spot]

      result = self.fight_result?(agg_rank, def_rank)
      # Aggressor won
      if result == :won
        @game[def_side].delete(spot)

        if agg_side != @game[:other_player]
          @ai.cheat(nil, spot, agg_rank)
        end

        {:status => :won, :defender => def_rank, :pieces => [{:player => def_side, :rank => def_rank}]}
      # Defender won
      elsif result == :lost
        @game[agg_side].delete(spot)
        @ai.dead(spot)

        {:status => :won, :defender => def_rank, :pieces => [{:player => agg_side, :rank => agg_rank}]}
      # Both sides lost, both pieces destroyed
      elsif result == :tie
        @game[def_side].delete(spot)
        @game[agg_side].delete(spot)
        @ai.dead(spot)

        {:status => :won, :defender => def_rank, :pieces => [{:player => agg_side, :rank => agg_rank}, {:player => def_side, :rank => def_rank}]}
      end
    end

    private
    def fight_result?(aggressor, defender)
      # Empty spot, nothing to fight
      return nil if defender.nil?
      # Anyone attacking the flag straight wins
      return :won if defender == :F

      agg_piece = @game_data[:pieces][aggressor]
      def_piece = @game_data[:pieces][defender]

      # The defending piece counters, such as a bomb
      if def_piece[:counters].include?(aggressor) and def_piece[:counters_when] == :attacked
        :lost
      # The attacker has an overriding counter such as a Spy against a Marshal or a Miner vs a Bomber
      elsif agg_piece[:counters].include?(defender) and agg_piece[:counters_when] == :attacker
        :won
      # Both pieces are killed off by default
      elsif agg_piece[:rank] == def_piece[:rank]
        :tie
      elsif agg_piece[:rank] > def_piece[:rank]
        :won
      else
        :lost
      end
    end
  end
end
