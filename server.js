
zmq = require('zmq');

cmds = zmq.createSocket('req');
cmds.connect("tcp://127.0.0.1:5556");

events = zmq.createSocket('sub');
events.connect("tcp://127.0.0.1:5555");
events.subscribe(new Buffer(""));

events.on("message", function(msg) {
  console.log(msg.toString());
});

cmds.on("message", function(msg){
  console.log("[CMD]", msg.toString());
});

cmds.send("get_video_mode");
cmds.send("get_cutoff");

