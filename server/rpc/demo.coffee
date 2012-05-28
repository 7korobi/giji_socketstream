# Server-side Code
# Define actions which can be called from the client using ss.rpc('demo.ACTIONNAME', param1, param2...)
# Example of pre-loading sessions into req.session using internal middleware
# Uncomment line below to use the middleware defined in server/middleware/example

exports.actions = (req, res, ss) ->
  db = require './models/trpg'

  req.use 'session'
#  req.use 'trpg.authenticated'

  initialize: (params)->
    db.TrpgEvent.findById params.event_id, (err,doc)->
      console.log err
      console.log doc

    db.User.findOne rails_token: params.rails_token, (err,doc)->
      console.log err
      console.log doc


  sendMessage: (message, event_id) ->
    if message && message.length > 0            # Check for blank messages
      ss.publish.all('newMessage', message)     # Broadcast the message to everyone
      res(true)                                 # Confirm it was sent to the originating client
    else
      res(false)
