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
    cyclonedef: [:SC, :MAJ, :MI, :SC, :CA, :LI, :MAJ, :SC, :CO, :B, :MAR, :CA, :B, :MI, :CO, :CA, :MI, :MI, :B, :SE, :S, :B, :F, :B, :MI, :GE, :LI, :SC, :SE, :CA, :MAJ, :SE, :B, :SE, :SC, :SC, :LI, :SC, :LI, :SC]
  },
  pieces: {
    MAR: {rank: 10, avail: 1, name: "Marshal"},
    GE: {rank: 9, :avail => 1, :name => "General"},
    CO: {rank: 8, :avail => 2, :name => "Colonel"},
    MAJ: {rank: 7, :avail => 3, :name => "Major"},
    CA: {rank: 6, :avail => 4, :name => "Captain"},
    LI: {rank: 5, :avail => 4, :name => "Lieut"},
    SE: {rank: 4, :avail => 4, :name => "Serg"},
    MI: {rank: 3, :avail => 5, :name => "Miner", :counters => [:B], :counters_when => :attacker},
    SC: {rank: 2, :avail => 8, :name => "Scout"},
    S: {rank: 1, :avail => 1, :name => "Spy", :text_rank => "S", counters: [10], :counters_when => :attacker},
    F: {rank: 0, :avail => 1, :name => "Flag", :text_rank => "F", :unmovable => true},
    B: {rank: 0, :avail => 6, :name => "Bomb", :text_rank => "B", counters: (4..10).to_a << 2, :counters_when => :attacked, :unnmovable => true}
  }
}

GAME_DATA[:classic][:pieces].each {|k, v| v[:counters] ||= []}