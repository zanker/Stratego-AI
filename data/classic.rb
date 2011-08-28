GAME_DATA[:classic] = {
  map: {
    width: 10,
    height: 10,
    spots: 100,
    blocked: [43, 44, 47, 48, 53, 54, 57, 58],
    blue: {:start => 1, :end => 40, :total => 40},
    red: {:start => 61, :end => 100, :total => 40},
  },
  templates: {
    cyclonedef: [2, 7, 3, 2, 6, 5, 7, 2, 8, :B, 10, 6, :B, 3, 8, 6, 3, 3, :B, 4, :S, :B, :F, :B, 3, 9, 5, 2, 4, 6, 7, 4, :B, 4, 2, 2, 5, 2, 5, 2]
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

GAME_DATA[:classic][:pieces][10].merge!(:avail => 1, :name => "Marshal", :id => "MAR")
GAME_DATA[:classic][:pieces][9].merge!(:avail => 1, :name => "General", :id => "GE")
GAME_DATA[:classic][:pieces][8].merge!(:avail => 2, :name => "Colonel", :id => "CO")
GAME_DATA[:classic][:pieces][7].merge!(:avail => 3, :name => "Major", :id => "MAJ")
GAME_DATA[:classic][:pieces][6].merge!(:avail => 4, :name => "Captain", :id => "CA")
GAME_DATA[:classic][:pieces][5].merge!(:avail => 4, :name => "Lieut", :id => "LI")
GAME_DATA[:classic][:pieces][4].merge!(:avail => 4, :name => "Serg", :id => "SE")
GAME_DATA[:classic][:pieces][3].merge!(:avail => 5, :name => "Miner", :id => "MI")
GAME_DATA[:classic][:pieces][2].merge!(:avail => 8, :name => "Scout", :id => "SC")
GAME_DATA[:classic][:pieces][:S].merge!(:avail => 1, :name => "Spy", :id => "SP")
GAME_DATA[:classic][:pieces][:F].merge!(:avail => 1, :name => "Flag", :id => "FL")
GAME_DATA[:classic][:pieces][:B].merge!(:avail => 6, :name => "Bomb", :id => "BO")
