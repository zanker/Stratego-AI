var Stratego = {
  actions: {
    loaded: function() {
      $("#message").text("Ready to play, click \"Start a new game\" to begin game vs the computer.");

      $("#start input").attr("disabled", null);
      $("#start input").click(function() { Stratego.actions.setup_game(); });
    },

    error: function(data) {
      $("#error").text(data).show();
    },

    // Let the playe rchoose locations
    setup_game: function() {
      $("#game").css({border: "1px solid black"})
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
      Stratego.actions[response.action](response);
    };
  }
};