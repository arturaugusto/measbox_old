// measbox_automation.js 0.1
// (c) 2015 Artur Augusto Martins
// gum.js is freely distributable under the GPL v2 license.
// For all details and documentation:
// https://github.com/arturaugusto/measbox_automation
(function() {
  var MBAuto = function(addr, hot){
    var that = this;
    this.socket = null;
    this.isopen = false;
    this.socket = new WebSocket(addr);
    this.socket.binaryType = "arraybuffer";

    this.socket.onopen = function() {
      console.log("Connected!");
      that.isopen = true;
    }

    this.socket.onmessage = function(e) {
      if (typeof e.data == "string") {
        //console.log("Data received: " + e.data);
        var data = JSON.parse(e.data);
        //recive callback from automation server
        hot[data.func].apply(null, data.args);
      }
    }

    this.socket.onclose = function(e) {
      console.log("Connection closed.");
      that.socket = null;
      that.isopen = false;
    }


    // Make the function wait until the connection is made...
    this.waitForSocketConnection = function(socket, callback){
      setTimeout(
        function () {
          if (that.socket.readyState === 1) {
            if(callback != null){
              callback();
            }
            return;
          } else {
            console.log("wait for connection...");
            that.waitForSocketConnection(that.socket, callback);
          }
        }
      , 5); // wait 5 milisecond for the connection...
    }

    this.sendTask = function(json) {
      that.waitForSocketConnection(that.socket, function(){
        that.socket.send(JSON.stringify(json));
        console.log("Task sent.");
      })
    };

  }
  window.MBAuto = MBAuto;
})();