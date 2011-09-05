class Combat
  def initialize(game, game_data)
    @game, @game_data = game, game_data
  end

  def fight(agg_side, aggressor, defender)
    # Empty spot, nothing to fight
    return nil if defender.nil?
    # Anyone attacking the flag straight wins
    return :won if defender == :F

    agg_piece = @game_data[:pieces][aggressor]
    def_piece = @game_data[:pieces][defender]

    @game[:last_fight][:enemy_piece] = defender

    # The defending piece counters, such as a bomb
    if def_piece[:counters].include?(aggressor) and def_piece[:counters_when] == :attacked
      @game[:last_fight][:pieces] = [{:player => agg_side, :rank => aggressor}]
      :lost
    # The attacker has an overriding counter such as a Spy against a Marshal or a Miner vs a Bomber
    elsif agg_piece[:counters].include?(defender) and agg_piece[:counters_when] == :attacker
      @game[:last_fight][:pieces] = [{:player => flip_side(agg_side), :rank => defender}]
      :won
    # Both pieces are killed off by default
    elsif agg_piece[:rank] == def_piece[:rank]
      @game[:last_fight][:pieces] = [{:player => agg_side, :rank => aggressor}]
      @game[:last_fight][:pieces] = [{:player => flip_side(agg_side), :rank => defender}]
      :tie
    elsif agg_piece[:rank] > def_piece[:rank]
      @game[:last_fight][:pieces] = [{:player => flip_side(agg_side), :rank => defender}]
      :won
    else
      @game[:last_fight][:pieces] = [{:player => agg_side, :rank => aggressor}]
      :lost
    end
  end

  def flip_side(side)
    side == :blue && :red || :blue
  end
end