GAME_DATA[:classic] = {
  map: {
    width: 10,
    height: 10,
    spots: 100,
    blocked: [43, 44, 47, 48, 53, 54, 57, 58],
    blue: {:start => 1, :end => 40},
    red: {:start => 61, :end => 100},
  },
  pieces: {
    S: {counters: [10], :counters_on => :aggression},
    F: {counters: []},
    B: {counters: (4..10).to_a << 2}
  }
}

(3..10).each do |rank|
  GAME_DATA[:classic][:pieces][rank] = {counters: (2..rank).to_a}
end

GAME_DATA[:classic][:pieces][3][:counters].push(:B)
GAME_DATA[:classic][:pieces][2] = {counters: []}

GAME_DATA[:classic][:pieces][10].merge(:avail => 1, :name => "Marshal")
GAME_DATA[:classic][:pieces][9].merge(:avail => 1, :name => "General")
GAME_DATA[:classic][:pieces][8].merge(:avail => 2, :name => "Colonel")
GAME_DATA[:classic][:pieces][7].merge(:avail => 3, :name => "Major")
GAME_DATA[:classic][:pieces][6].merge(:avail => 4, :name => "Captain")
GAME_DATA[:classic][:pieces][5].merge(:avail => 4, :name => "Lieutenant")
GAME_DATA[:classic][:pieces][4].merge(:avail => 4, :name => "Sergeant")
GAME_DATA[:classic][:pieces][3].merge(:avail => 5, :name => "Miner")
GAME_DATA[:classic][:pieces][2].merge(:avail => 8, :name => "Scout")
GAME_DATA[:classic][:pieces][:S].merge(:avail => 1, :name => "Spy")
GAME_DATA[:classic][:pieces][:F].merge(:avail => 6, :name => "Bomb")
GAME_DATA[:classic][:pieces][:B].merge(:avail => 1, :name => "Flag")

