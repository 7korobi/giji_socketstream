# Server-side Code
# Define actions which can be called from the client using ss.rpc('demo.ACTIONNAME', param1, param2...)
# Example of pre-loading sessions into req.session using internal middleware
# Uncomment line below to use the middleware defined in server/middleware/example

require '../config.coffee'

giji = require '../models/giji.coffee'
trpg = require '../models/trpg.coffee'
exports.story = {}
exports.event = {}
exports.stat  = {}


class Stat
  initialize: (rails_token, cb)->

    key = rails_token: rails_token
    giji.User.findOne key, (err, doc)=>
      if doc
        @is_admin = doc.is_admin
        @user_id  = doc._id
        cb(doc)
      else
        @error('User', rails_token, err)

  fetch: (type, key, ok)->
    doc = exports[type][key] 
    if doc
      @[type] = doc
      @["#{type}_id"] = doc._id
      ok(doc)
    else
      trpg[type.camelize()].findById key, (err, doc)=>
        if doc
          exports[type][key] = doc
          @[type] = doc
          @["#{type}_id"] = doc._id
          ok(doc)
        else
          @error(type, key, err)

  near_potof: (cb)->
    trpg.Potof.findOne  story_id: @story_id, user_id: @user_id, (err, potof)=>
      @potof = potof if potof
      cb(err, potof)

  new_potof: ->
    @potof = new trpg.Potof 
      user_id:  @user_id
      event_id: @event_id
      story_id: @story_id

  is_author: -> false
  is_actor: -> @user_id? && ! @story.is_finish
  is_here: -> @event_id == @potof.event_id

  enable_entry:  -> @enable_open() && 0 == @event.turn
  enable_open:   -> @is_actor()  && 'OPEN' == @event.state 
  enable_invite: -> @is_author() && ('OPEN' == @event.state || 'INVITE' == @event.state)
  enable_secret: -> @is_actor()  && 'SECRET' == @event.state 

Stat.memory = (id)->
  exports.stat[id] = exports.stat[id] || new Stat()


exports.actions = (req, res, ss) ->
  req.use 'session'
  stat = Stat.memory(req.sessionId)
  req.to_self = (rpc, data)->
    if req.session.ready?
      ss.publish.channel @sessionId, rpc, data
    else
      ss.publish.socketId @socketId, rpc, data
  req.to_pub = (rpc, data)->
    ss.publish.channel # stat.event_id

  info  = (data)->  req.to_self  'infoFrame', data
  form  = (data)->  req.to_self  'formFrame', data
  log   = (data)->  req.to_self   'logFrame', data
  title = (data)->  req.to_self 'titleFrame', data
  pub   = (data)->  req.to_pub  

  abort_potof = (err)-> info "更新できませんでした。"         if err?
  abort_event = (err)-> info "イベントを更新できませんでした。" if err?

  initialize: (rails_token, event_id)->
    req.session.ready = null
    stat.error = (type, key, err)->
      info "missing #{type}."
    stat.initialize rails_token, (user)->
      req.session.setUserId(user._id)
      info "ルールを良く理解した上でご参加ください。"

    stat.fetch 'event', event_id, (event)->
      stat.fetch 'story', event.story_id, (story)->
        req.session.channel.reset()
        req.session.channel.subscribe event._id
        req.session.channel.subscribe req.sessionId
        title event.name
        log   event.messages

        stat.near_potof (err, potof)->
          if potof
            switch event.state
              when 'OPEN'
                form
                  'form-actor': potof
                  'form-bye':   potof
                req.session.ready = true
                req.session.save()
              else
                form
                  'form-actor': potof
                req.session.ready = true
                req.session.save()
          else
            switch event.state
              when 'OPEN'
                giji.Face.findSelectOptions (err,doc)-> 
                  form
                    'form-entry':
                      faces: doc
                  req.session.ready = true
                  req.session.save()
              else
                info "このイベントには参加できません。"
                req.session.ready = true
                req.session.save()

  entryPotof: (face_id, prefix, name)->
    return info "選択が無効です。"         unless face_id && ! face_id.isBlank()
    return info "肩書きが無効です。"       unless prefix  && ! prefix.isBlank()
    return info "選択が無効です。"         unless name    && ! name.isBlank()
    return info "イベントが開いていません。" unless stat.enable_open()

    stat.near_potof (err, potof)->
      if potof
        potof.event_id = stat.event_id
      else
        potof = stat.new_potof(face_id, prefix, name)
      potof.face_id = face_id
      potof.fullname = "#{prefix} #{name}"
      potof.name = name
      potof.save abort_potof

      form.delay 500
        'form-join': potof
      
  joinPotof: ->
    stat.near_potof (err, potof)->
      if potof
        potof.event_id = stat.event_id
        potof.save abort_potof
        form
          'form-actor': potof

  byePotof: ->
    stat.near_potof (err, potof)->
      if potof
        stat.potof = null
        potof.remove()

    switch stat.event.state
      when 'OPEN'
        giji.Face.findSelectOptions (err,doc)-> 
          form
            'form-entry':
              faces: doc

  newEvent: ->

  editEvent: (data)->
    stat.event.update(data)
    stat.event.save abort_event

    switch data.state
      when 'OPEN'
        1
      when 'INVITE'
        1
      when 'SECRET'
        1
      when 'CLOSE'
        event_id = stat.event_id
        exports.stat.each (id, stat)->
          return unless event_id == stat.potof.event_id
          exports.stat[id]    = null
          stat.potof.event_id = null
          stat.potof.save abort_potof
    pub
  sayMessage: ->
