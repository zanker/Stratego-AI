class Movement
  def initialize(game, game_data, last_move)
    @game, @game_data, @last_move = game, game_data, last_move
  end

  def spot_area(spot)
    return ((spot - 1) % @game_data[:map][:width]), ((spot - 1.0) / @game_data[:map][:height]).floor
  end

  def is_line_valid?(spot_id, moved, offset)
    total_enemies = 0
    need_enemy = @game[@game[:other_player]][spot_id + (moved * offset)]

    (1..moved).each do |i|
      map_id = spot_id + (i * offset)
      # Moving through a blocked area
      return false if @game_data[:map][:blocked].include?(map_id)
      # Moving through one of our own pieces
      return false if @game[@game[:move]][map_id]

      # Figure out how many bad guys are in our path
      total_enemies += 1 if @game[@game[:other_player]][map_id]
    end

    # As long as a line has <= 1 enemy, it's valid.
    # You obviously can't move through multiple
    if need_enemy
      total_enemies == 1
    else
      total_enemies == 0
    end
  end

  def is_valid?(from, to)
    # We're trying to move something that's not ours
    return false unless @game[@game[:move]][from]
    # Moving into a blocked space
    return false if @game_data[:map][:blocked].include?(to)
    # Moving to somewhere with one of our pieces
    return false if @game[@game[:move]][to]

    piece = @game_data[:pieces][@game[@game[:move]][from]]
    return false if piece[:unmovable]

    from_horz, from_vert = spot_area(from)
    to_horz, to_vert = spot_area(to)

    # Scout, can move any number of spots up/down/left/right
    if piece[:id] == "SC"
      # We're moving up or down
      if from_horz == to_horz
        offset = @game_data[:map][:height] * (from_vert > to_vert ? -1 : 1)
        return is_line_valid?(from, (from_vert - to_vert).abs, offset)
      # Moving left or right
      elsif to_vert == to_vert
        return is_line_valid?(from, (from_horz - to_horz).abs, (from_horz > to_horz ? -1 : 1))
      # Doing something we shouldn't be!
      else
        return false
      end
    end

    # General movement either up, down, left or right
    if from_horz == to_horz
      return (from_vert - to_vert).abs == 1
    elsif from_vert == to_vert
      return (from_horz - to_horz).abs == 1
    end

    false
  end
end