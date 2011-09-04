var Stratego = {
  status: {},
  // Small helper functions
  pad_number: function(number) { return number < 10 ? ("0" + number) : number; },
  reverse_side: function(side) { return side == "blue" ? "red" : "blue"; },

  // Movement checks
  is_line_valid: function(spot_id, needs_enemy, total, offset) {
    // Check the entire line, if it's blocked or another one of our pieces is in it then it's invalid.
    var total_enemies = 0, spot, i;
    for( i=1; i <= total; i++ ) {
      spot = Stratego.spot_map[spot_id + (i * offset)];
      if( spot.hasClass("blocked") || spot.find(".piece." + Stratego.status.player).length == 1 ) return false;
      if( spot.find(".piece." + Stratego.status.other_player).length == 1 ) total_enemies += 1;
    }

    // We're ending up on a spot that has an enemy, we must have at least one enemy
    if( needs_enemy ) {
      return total_enemies == 1;
    // Otherwise we're ending up on a spot without enemies, so any enemies in the line is bad
    } else {
      return total_enemies == 0;
    }
  },

  is_move_valid: function(from, to) {
    var from_rank = from.find(".piece").data("rank-id");
    // Either it's blocked (terrain) or we have a piece on that area already
    if( to.hasClass("blocked") || to.find(".piece." + Stratego.status.player).length == 1 ) return;

    var from_spot = from.data("spot"), to_spot = to.data("spot");
    var from_horz = this.horz_area(from_spot), to_horz = this.horz_area(to_spot);
    var from_vert = this.vert_area(from_spot), to_vert = this.vert_area(to_spot);

    // Scouts can move any distance in a straight line.
    if( from_rank == "SC" ) {
      var needs_enemy = to.find(".piece." + Stratego.status.other_player).length == 1;

      // Moving up or down
      if( from_horz == to_horz ) {
        var offset = Stratego.game_data.map.height * (from_vert > to_vert ? -1 : 1);
        return Stratego.is_line_valid(from_spot, needs_enemy, Math.abs(from_vert - to_vert), offset);
      // Moving left or right
      } else if( from_vert == to_vert ) {
        return Stratego.is_line_valid(from_spot, needs_enemy, Math.abs(from_horz - to_horz), (from_horz > to_horz ? -1 : 1));
      // Invalid otherwise
      } else {
        return false;
      }
    }

    // Everyone else can only move one spot up/down or left/right
    if( from_horz == to_horz ) {
      return ( Math.abs(from_vert - to_vert) == 1 );
    } else if( from_vert == to_vert ) {
      return ( Math.abs(from_horz - to_horz) == 1 );
    }

    return false;
  },

  // Turn our spots into labels using chess labeling
  letters: ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"],
  vert_area: function(spot) {
    return Math.floor((spot - 1) / Stratego.game_data.map.height);
  },
  horz_area: function(spot) {
    return (spot - 1) % Stratego.game_data.map.width;
  },
  spot_to_label: function(spot) {
    return this.letters[this.horz_area(spot)] + (Stratego.game_data.map.height - this.vert_area(spot));
  },

  actions: {
    loaded: function() {
      $("#message").text("Ready to play, click \"Start a new game\" to begin game vs the computer.");

      $("#start input").attr("disabled", null);
      $("#start input").click(function() { Stratego.respond("gamedata", "classic"); });

      // DEBUG
      $("#start input").click();
      setTimeout(function() {
        $("#templates input[data-template='cyclonedef']").click();

        setTimeout(function() { $("#start input[type='button']").click(); }, 10);
      }, 10);
    },

    error: function(data) {
      $("#error").show().text(data);
    },

    // Let the player choose locations
    setup: function(data) {
      Stratego.game_data = data;
      Stratego.status.player = "red";
      Stratego.status.other_player = "blue";
      Stratego.spot_map = {};

      // Load the game board
      var blocked = {};
      for( var i=0, total=data.map.blocked.length; i < total; i++ ) blocked[data.map.blocked[i]] = true;

      var spot, j, piece, html = "";
      for( i=0; i < data.map.height; i++ ) {
        html += "<tr>";
        for( j=1; j <= data.map.width; j++ ) {
          spot = (i * 10) + j;
          html += "<td class='spot" + (blocked[spot] ? " blocked" : "") + "' data-spot='" + spot + "' id='gamespot" + spot + "'>" + spot + "</td>";
        }

        html += "</tr>";
      }

      $("<table cellspacing='0'>" + html + "</table>").appendTo($("#board"));

      // Static list of the player pieces so we can quickly add them in a consistently organized way
      var pieces = [];
      for( var key in data.pieces ) {
        for( i=0; i < data.pieces[key].avail; i++ ) pieces.push(key);
      }

      // Load pieces
      $("#board td").each(function(id, spot) {
        spot = $(spot);
        var spot_id = spot.data("spot");
        Stratego.spot_map[spot_id] = spot;

        if( spot_id >= data.map.blue.start && spot_id <= data.map.blue.end ) {
          $("<div class='piece blue' id='gamepiece" + spot_id + "'></div>").appendTo(spot);
        } else if( spot_id >= data.map.red.start && spot_id <= data.map.red.end ) {
          var rank = pieces.shift();

          $("<div class='piece red piece-" + rank + " pointer' data-rank-id='" + rank + "' id='gamepiece" + spot_id + "'><div class='name'>" + data.pieces[rank].name + "</div><div class='rank'>" + (Stratego.game_data.pieces[rank].text_rank || Stratego.game_data.pieces[rank].rank) + "</div></div>").appendTo(spot);
        }
      });

      // Label horizontal, A - Z
      html = "<ul>";
      for( i=0; i < data.map.width; i++ ) {
        html += "<li>" + Stratego.letters[i] + "</li>";
      }

      $(".horz-spots").html(html + "</ul>");

      // Label vertical, 1 - X
      html = "<ul>";
      for( i=data.map.height; i > 0; i-- ) {
        html += "<li>" + i + "</li>";
      }

      $(".vert-spots").html(html + "</ul>");

      // Initial setup hook, will kill this off later
      var player_pieces = $("#board table .piece." + Stratego.status.player);
      var active_piece;
      $("#board table .spot").click(function() {
        var target = $(this);
        var piece = target.find(".piece");

        if( piece.hasClass(Stratego.status.player) ) {
          // Deselect
          if( active_piece == piece ) {
            active_piece.removeClass("highlight");
            active_piece = null;

          // Next click we swap unless they reclick the same piece
          } else if( !active_piece ) {
            piece.addClass("active");

            active_piece = piece;

          // Swap positions
          } else {
            piece.detach().appendTo(active_piece.closest(".spot"));
            active_piece.detach().appendTo(target).removeClass("active");

            active_piece = null;
          }
        }
      });

      // For setting up with a predefined template
      $("#templates input[type='button']").click(function() {
        player_pieces.removeClass("highlight");

        var template = data.templates[$(this).data("template")];
        var spot_i = data.map[Stratego.status.player].start;

        var pieces = {};
        $(".piece." + Stratego.status.player).each(function(id, row) {
          if( pieces[row.getAttribute("data-rank-id")] == null ) pieces[row.getAttribute("data-rank-id")] = [];
          pieces[row.getAttribute("data-rank-id")].push(row);
        });

        for( i=0, total=template.length; i < total; i++ ) {
          var piece = $(pieces[template[i]].shift());
          piece.appendTo(Stratego.spot_map[spot_i]);

          spot_i++;
        }
      });

      $("#message").text("Setup phase, click on a piece and then another piece to do your initial setup. Click \"Play\" when ready.");
      $("#templates").show();

      $("#start input").val("Play");
      $("#start input ").unbind("click").click(function() {
        var setup = {};
        $(".piece." + Stratego.status.player).each(function(id, row) {
          row = $(row);
          setup[row.closest(".spot").data("spot")] = row.data("rank-id");
        });

        Stratego.respond("start_game", setup);
      });
    },

    // Time to go
    start: function(data) {
      Stratego.status.move = data.move;

      $("#start").hide();
      $("#templates").hide();
      $("#board table .spot").unbind("click");

      $("#message").html("Time to play! Its <span class='" + data.move + "-player'>" + data.move + "s</span> move." + (data.move == Stratego.status.player ? " Click a piece and then a spot to move." : "AI's turn."));
      $(".playerstatus, #history").show();

      var active_spot;
      $("#board table .spot").click(function() {
        var spot = $(this), piece = $(this).find(".piece");
        if( Stratego.status.move != Stratego.status.player ) return;

        // Deselecting an existing spot
        if( active_spot && active_spot.attr("id") == spot.attr("id") ) {
          $("#board table td.pointer").removeClass("pointer");
          piece.removeClass("active");
          active_spot = null;

        // We already selected a spot, so we need to make sure it's valid to move onto
        } else if( active_spot ) {
          if( !Stratego.is_move_valid(active_spot, spot) ) {
            $("#message").html("<span class='red'>You cannot move from " + Stratego.spot_to_label(active_spot.data("spot")) + " to " + Stratego.spot_to_label(spot.data("spot")) + "</span>");
            return;
          }

          $("#board table td.pointer").removeClass("pointer");
          if( spot.find(".piece." + Stratego.status.other_player).length == 1 ) {
            $("#message").html("Moving from <span class='" + Stratego.status.player + "-player'>" + Stratego.spot_to_label(active_spot.data("spot")) + "</span> to <span class='" + Stratego.status.other_player + "-player'>" + Stratego.spot_to_label(spot.data("spot")) + "</span> and attacking");
          } else {
            $("#message").html("Moving from <span class='" + Stratego.status.player + "-player'>" + Stratego.spot_to_label(active_spot.data("spot")) + "</span> to " + Stratego.spot_to_label(spot.data("spot")));
          }

          active_spot.find(".piece").removeClass("active");
          Stratego.status.move = Stratego.status.other_player;

          Stratego.respond("move", {from: active_spot.data("spot"), to: spot.data("spot")});
          active_spot = null;

        // Nothing selected yet, only can select our spots
        } else if( piece.find(Stratego.status.player) )  {
          if( piece.data("rank-id") == "FL" || piece.data("rank-id") == "BO" ) {
            $("#message").html("<span class='red'>You can only move that piece during setup.</span>");
            return;
          }

          piece.addClass("active");
          $("#board table td[class='spot']").addClass("pointer");
          active_spot = spot;
        }

      });
    },

    // Movement
    moved: function(data) {
      Stratego.status.move = data.move;

      var time = (new Date());
      time = Stratego.pad_number(time.getHours()) + ":" + Stratego.pad_number(time.getMinutes()) + ":" + Stratego.pad_number(time.getSeconds());

      var moved_to = "no-player", result = "";
      if( data.result == "won" || data.result == "lost" ) {
        moved_to = data.other_player + "-player";
        result = "<span class='" + moved_to + "'>(" + data.result + ")</span>";

        var target = data.result == "won" ? data.mover : Stratego.reverse_side(data.mover);
        // Update counter since we lost a piece we already
        var li = $("li[data-rank='" + data.lost_piece);
        if( li.length > 1 ) {
          li.data("lost", li.data("lost") + 1);
          li.val(li.data("lost") + " x " + Stratego.game_data.pieces[data.lost_piece].name);
        // New piece lost
        } else {
          $("<li data-rank='" + data.lost_piece + "' data-lost='1'>1 x " + Stratego.game_data.pieces[data.lost_piece].name + "</li>").appendTo("#" + target + "-status .captured");
        }

        var counter = $("#" + target + "-status .count");
        counter.val(counter.val() + 1);
      }

      $("<li><span class='time'>[" + time + "]</span> <span class='" + data.mover + "-player'>" + Stratego.spot_to_label(data.from) + "</span> -> <span class='" + moved_to + "'>" + Stratego.spot_to_label(data.to) + "</span>" + result + "</li>").appendTo($("#logs"));
    },
    bad_move: function(data) {
      Stratego.status.move = data.move;
      $("#message").html("<span class='red'>You cannot move from " + Stratego.spot_to_label(data.from) + " to " + Stratego.spot_to_label(data.to) + "</span>");
    }
  },

  respond: function(type, data) {
    this.socket.send(JSON.stringify({action: type, data: data}));
  },

  initialize: function() {
    if( !("WebSocket" in window) ) {
      $("#error").val("Sorry, but you do not have a browser that supports WebSockets. You might need to enable it").show();
      return;
    }

    this.socket = new WebSocket("ws://localhost:5000");
    this.socket.onopen = function() { Stratego.actions.loaded(); };
    this.socket.onerror = function(event) { Stratego.actions.error(event.data); };
    this.socket.onmessage = function(event) {
      response = JSON.parse(event.data);
      Stratego.actions[response.action](response.data);
    };
  }
};