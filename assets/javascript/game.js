var Stratego = {
  actions: {
    loaded: function() {
      $("#message").text("Ready to play, click \"Start a new game\" to begin game vs the computer.");

      $("#start input").attr("disabled", null);
      $("#start input").click(function() { Stratego.respond("gamedata", "classic"); });

      $("#start input").click();
    },

    error: function(data) {
      $("#error").show().text(data);
    },

    // Let the player choose locations
    setup: function(data) {
      Stratego.game_data = data;
      Stratego.spot_map = {};

      // Load the game board
      var blocked = {};
      for( var i=0, total=data.map.blocked.length; i < total; i++ ) blocked[data.map.blocked[i]] = true;

      var j, piece, html = "";
      for( i=0; i < data.map.height; i++ ) {
        html += "<tr>"
        for( j=1; j <= data.map.width; j++ ) {
          spot = (i * 10) + j;
          html += "<td class='spot" + (blocked[spot] ? " blocked" : "") + "' data-spot='" + spot + "' id='gamespot" + spot + "'>" + spot + "</td>";
        }

        html += "</tr>";
      }

      $("<table cellspacing='0'>" + html + "</table>").appendTo($("#board"));

      // Static list of pieces that we add in so they can movie it
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
          $("<div class='piece red piece-" + rank + " pointer' data-rank='" + rank + "' id='gamepiece" + spot_id + "'><div class='name'>" + data.pieces[rank].name + "</div><div class='rank'>" + rank + "</div></div>").appendTo(spot);
        }
      });

      // Initial setup hook, will kill this off later
      var player_pieces = $("#board table .piece.red");
      var active_piece;
      $("#board table .spot").click(function() {
        var target = $(this);
        var piece = target.find(".piece");

        if( piece.hasClass("red") ) {
          // Deselect
          if( active_piece == piece ) {
            active_piece = null;
            player_pieces.removeClass("highlight");

          // Next click we swap unless they reclick
          } else if( !active_piece ) {
            player_pieces.addClass("highlight");
            piece.removeClass("highlight").addClass("active");

            active_piece = piece;

          // Swap positions
          } else {
            piece.detach().appendTo(active_piece.closest(".spot"));
            active_piece.detach().appendTo(target).removeClass("active");

            active_piece = null;
            player_pieces.removeClass("highlight");
          }
        }
      });

      // For setting up with a predefined template
      $("#templates input[type='button']").click(function() {
        var template = data.templates[$(this).data("template")];
        var spot_i = data.map.red.start;

        var pieces = {};
        $(".piece.red").each(function(id, row) {
          if( pieces[row.getAttribute("data-rank")] == null ) pieces[row.getAttribute("data-rank")] = [];
          pieces[row.getAttribute("data-rank")].push(row);
        });

        for( i=0, total=template.length; i < total; i++ ) {
          var piece = $(pieces[template[i]].shift());
          piece.appendTo(Stratego.spot_map[spot_i]);

          spot_i++;
        }
      });

      $("#message").text("Setup phase, click on a piece and then another piece to do your initial setup. Click \"Play\" when ready.");
      $("#start input").val("Play");
      $("#templates").show();
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