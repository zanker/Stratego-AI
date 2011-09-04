class Combat
  def initialize(game, game_data)
    @game, @game_data = game, game_data
  end

  def fight(aggressor, defender)
    # Empty spot, nothing to fight
    return nil if defender.nil?
    # Anyone attacking the flag straight wins
    return :won if defender == :F

    agg_piece = @game_data[:pieces][aggressor]
    def_piece = @game_data[:pieces][defender]

    # The defending piece counters, such as a bomb
    if def_piece.counters.include?(aggressor) and def_piece.counters_when == :attacked
      :lost
    # The attacker has an overriding counter such as a Spy against a Marshal or a Miner vs a Bomber
    elsif agg_piece.counters.include?(defender) and agg_piece.counters_when == :attacker
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