
zmq = require 'zmq'
{EventEmitter} = require 'events'

class KinectGuard extends EventEmitter

  @simpleCommands =
    switchToRGB: 'switch_to_rgb'
    switchToIR: 'switch_to_rgb'
    getCutoff: 'get_cutoff'
    getVideoMode: 'get_video_mode'
    writeBMP: 'write_bmp'

  constructor: ->
    @listeners = {}
    @cmds = zmq.createSocket 'req'
    @cmds.connect 'tcp://127.0.0.1:5556'

    @events = zmq.createSocket 'sub'
    @events.connect 'tcp://127.0.0.1:5555'
    @events.subscribe(new Buffer "")

    @initCommands()

    @events.on 'message', (msg) ->
      vals = msg.split ' '
      @emit.apply(@, vals)

    @cmds.on 'message', (msg) ->
      vals = msg.split ' '
      cmd = vals[0]
      fn = @listeners[cmd]

      if fn
        rest = if vals.length > 1 then vals[1..vals.length] else []
        fn.apply(rest)
        delete @listeners[cmd]

  doCmd: (cmd, cb) ->
    @cmds.send cmd
    @listeners[cmd] = cb

  initCommands:
    for key, value of @simpleCommands
      cmd = value, fnName = key
      @[fnName] = (cb) -> @doCmd cmd cb
