# Server-side Code
# Define actions which can be called from the client using ss.rpc('demo.ACTIONNAME', param1, param2...)
# Example of pre-loading sessions into req.session using internal middleware
# Uncomment line below to use the middleware defined in server/middleware/example
require '../config.coffee'


exports.stories = stories = {}
exports.events = events = {}
exports.list = list = {}


fetch = (cash, key, access, ok, ng)->
  doc = cash[key]
  if doc
    ok(doc)
  else
    access key, (err,doc)->
      if err
        ng(err)
      else
        cash[key] = doc
        ok(doc)


exports.actions = (req, res, ss) ->
  req.use 'session'
  giji = require '../models/giji.coffee'
  trpg = require '../models/trpg.coffee'

  initialize: (rails_token, event_id)->

    giji.User.findOne rails_token: rails_token, (err,user)->
      if err
        ss.publish.socketId  req.socketId, 'infoFrame', "接続できません。"
      else
        req.session.user = user
        req.session.setUserId(user._id)
        ss.publish.socketId  req.socketId, 'infoFrame', "ルールを良く理解した上でご参加ください。"

    bind_event = (event)->
      req.session.event = event
      req.session.channel.subscribe event_id

      fetch stories, event.story_id, (key, cb)->
        trpg.Story.findById key, cb
      , (story)->
        req.session.story = story
        ss.publish
      , (err)->
        ss.publish.socketId  req.socketId, 'infoFrame', "ストーリーがありません。"

      switch event.state
        when 'OPEN'
          giji.Face.findSelectOptions (err,doc)-> 
            ss.publish.socketId  req.socketId, 'formFrame',
              'form-entry':
                faces: doc
              'form-actor':
                id:   'admin'
                name: "闇のつぶやき（管理人）"
        else
          ss.publish.socketId  req.socketId, 'infoFrame', "このイベントには参加できません。"

    fetch events, event_id, (key, cb)->
      trpg.Event.findById event_id, cb
    , bind_event
    , (err)->
      ss.publish.socketId  req.socketId, 'infoFrame', "イベントがありません。"

    console.log req.session

  entryPotof: (face_id, prefix, name)->
    story = req.session.story
    event = req.session.event
    user  = req.session.user
    trpg.Potof.findOne event_id: event._id, user_id: user._id, (err, doc)->
      console.log [event._id, user._id]
      console.log doc
      if doc && story && event && user
      else
        console.log [story.is_open(), event.is_open()]
        if story.is_open() && event.is_open()
          potof = new trpg.Potof
            fullname: "#{prefix} #{name}"
            name:     name
            face_id:  face_id
            user_id:  user._id
            event_id: event._id
            story_id: story._id
          console.log potof.save()
          console.log potof
        else
          res(false)
    giji.Face.findSelectOptions (err,doc)-> 
      ss.publish.socketId.delay 500, req.socketId, 'formFrame',
        'form-entry':
          faces: doc
    res(true)

  sendMessage: (message, event_id) ->
    if message && message.length > 0            # Check for blank messages
      ss.publish.all('newMessage', message)     # Broadcast the message to everyone
      res(true)                                 # Confirm it was sent to the originating client
    else
      res(false)
