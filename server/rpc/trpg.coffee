# Server-side Code
# Define actions which can be called from the client using ss.rpc('demo.ACTIONNAME', param1, param2...)
# Example of pre-loading sessions into req.session using internal middleware
# Uncomment line below to use the middleware defined in server/middleware/example


exports.events = events = {}
exports.users  = users  = {}

exports.list = list = {}

exports.actions = (req, res, ss) ->
  req.use 'session'

  initialize: (params)->
    giji = require './models/giji.coffee'
    trpg = require './models/trpg.coffee'

    events[params.event_id] || trpg.Event.findById params.event_id, (err,doc)->
      events[params.event_id] = doc

    giji.User.findOne rails_token: params.rails_token, (err,doc)->
      users[params.rails_token] = doc

    giji.Face.findSelectOptions (err,doc)-> 
      list.faces = doc

    if events[params.event_id] || true
      req.session.channel.reset()
      req.session.channel.subscribe params.event_id

  
      ss.publish.socketId  req.socketId, 'infoFrame', "ルールを良く理解した上でご参加ください。"
      ss.publish.socketId  req.socketId, 'formFrame',
        'form-entry':
          faces: list.faces
        'form-actor':
          id:   'admin'
          name: "闇のつぶやき（管理人）"


  sendMessage: (message, event_id) ->
    if message && message.length > 0            # Check for blank messages
      ss.publish.all('newMessage', message)     # Broadcast the message to everyone
      res(true)                                 # Confirm it was sent to the originating client
    else
      res(false)
