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

      var blocked = {};
      for( var i=0, total=data.map.blocked.length; i < total; i++ ) blocked[data.map.blocked[i]] = true;

      var j, piece, html = "";
      for( i=0; i < data.map.height; i++ ) {
        html += "<tr>"
        for( j=1; j <= data.map.width; j++ ) {
          piece = (i * 10) + j;
          html += "<td class='piece" + (blocked[piece] ? " blocked" : "") + "' data-piece='" + piece + "' id='gamepiece" + piece + "'>" + piece + "</td>";
        }

        html += "</tr>";
      }

      $("<table cellspacing='0'>" + html + "</table>").appendTo($("#board"));



      $("#message").text("Setup phase, drag your pieces where you want and when you're ready click \"Play\".");
      $("#start input").val("Play");
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